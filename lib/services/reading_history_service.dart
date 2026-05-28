import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book_model.dart';
import '../models/reading_history_model.dart';

/// Service untuk CRUD riwayat membaca (hybrid: local + Firestore)
/// Local storage: SharedPreferences (untuk offline/unauthenticated)
/// Remote storage: Firestore users/{uid}/reading_history/{bookId}
class ReadingHistoryService {
  static final _firestore = FirebaseFirestore.instance;
  static const _localHistoryKey = 'reading_history_local';

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('history');

  // ── Local Storage (SharedPreferences) ────────────────────────────────

  /// Ambil semua history lokal dari SharedPreferences
  static Future<Map<String, ReadingHistoryModel>> _getLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_localHistoryKey);
    if (jsonStr == null) return {};

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) =>
          MapEntry(key, ReadingHistoryModel.fromJson(value as Map<String, dynamic>)));
    } catch (e) {
      debugPrint('[ReadingHistoryService] ⚠️ Error loading local history: $e');
      return {};
    }
  }

  /// Simpan history lokal ke SharedPreferences
  static Future<void> _saveLocalHistory(
      Map<String, ReadingHistoryModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(
      history.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_localHistoryKey, jsonStr);
  }

  /// Update satu entry history lokal
  static Future<void> _updateLocalHistoryEntry(
      ReadingHistoryModel entry) async {
    final history = await _getLocalHistory();
    history[entry.bookId] = entry;
    await _saveLocalHistory(history);
  }

  /// Hapus satu entry dari history lokal
  static Future<void> _deleteLocalHistoryEntry(String bookId) async {
    final history = await _getLocalHistory();
    history.remove(bookId);
    await _saveLocalHistory(history);
  }

  /// Sync history lokal ke Firestore (dipanggil saat user login)
  static Future<void> syncLocalHistoryToFirestore() async {
    final uid = _uid;
    if (uid == null) return; // User tidak login

    final localHistory = await _getLocalHistory();
    if (localHistory.isEmpty) return;

    debugPrint(
        '[ReadingHistoryService] 🔄 Syncing ${localHistory.length} local entries to Firestore');

    for (final entry in localHistory.values) {
      try {
        final existing = await _collection(uid).doc(entry.bookId).get();
        if (existing.exists) {
          // Jika sudah ada, update dengan data lokal jika lebih baru
          final remoteEntry =
              ReadingHistoryModel.fromFirestore(existing.data()!);
          if (entry.lastReadAt.isAfter(remoteEntry.lastReadAt)) {
            await _collection(uid).doc(entry.bookId).update(entry.toFirestore());
          }
        } else {
          // Jika belum ada, buat baru
          await _collection(uid).doc(entry.bookId).set(entry.toFirestore());
        }
      } catch (e) {
        debugPrint(
            '[ReadingHistoryService] ⚠️ Error syncing ${entry.bookId}: $e');
      }
    }

    // Setelah sync selesai, hapus history lokal (opsional, uncomment jika ingin)
    // await _saveLocalHistory({});
    debugPrint('[ReadingHistoryService] ✅ Sync complete');
  }

  // ── Streams ──────────────────────────────────────────────────────────

  /// Stream riwayat membaca terbaru (realtime)
  /// Jika user login: ambil dari Firestore
  /// Jika tidak: ambil dari local storage
  static Stream<List<ReadingHistoryModel>> watchRecentlyRead({int limit = 10}) {
    final uid = _uid;
    if (uid != null) {
      // User authenticated: ambil dari Firestore
      return _collection(uid)
          .orderBy('lastReadAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => ReadingHistoryModel.fromFirestore(doc.data()))
              .toList());
    } else {
      // User tidak authenticated: ambil dari local storage
      return Stream.periodic(const Duration(seconds: 1), (_) => null)
          .asyncMap((_) async {
        final history = await _getLocalHistory();
        final sorted = history.values.toList()
          ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
        return sorted.take(limit).toList();
      });
    }
  }

  /// Stream satu entri history buku tertentu
  static Stream<ReadingHistoryModel?> watchBookHistory(String bookId) {
    final uid = _uid;
    if (uid != null) {
      // User authenticated: ambil dari Firestore
      return _collection(uid)
          .doc(bookId)
          .snapshots()
          .map((doc) => doc.exists
              ? ReadingHistoryModel.fromFirestore(doc.data()!)
              : null);
    } else {
      // User tidak authenticated: ambil dari local storage
      return Stream.periodic(const Duration(seconds: 1), (_) => null)
          .asyncMap((_) async {
        final history = await _getLocalHistory();
        return history[bookId];
      });
    }
  }

  // ── One-time reads ───────────────────────────────────────────────────

  /// Ambil riwayat terbaru sekali
  static Future<List<ReadingHistoryModel>> getRecentlyRead({int limit = 10}) async {
    final uid = _uid;
    if (uid != null) {
      // User authenticated: ambil dari Firestore
      final snap = await _collection(uid)
          .orderBy('lastReadAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map((doc) => ReadingHistoryModel.fromFirestore(doc.data()))
          .toList();
    } else {
      // User tidak authenticated: ambil dari local storage
      final history = await _getLocalHistory();
      final sorted = history.values.toList()
        ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
      return sorted.take(limit).toList();
    }
  }

  /// Ambil history buku tertentu
  static Future<ReadingHistoryModel?> getBookHistory(String bookId) async {
    final uid = _uid;
    if (uid != null) {
      // User authenticated: ambil dari Firestore
      final doc = await _collection(uid).doc(bookId).get();
      if (!doc.exists) return null;
      return ReadingHistoryModel.fromFirestore(doc.data()!);
    } else {
      // User tidak authenticated: ambil dari local storage
      final history = await _getLocalHistory();
      return history[bookId];
    }
  }

  // ── Write operations ─────────────────────────────────────────────────

  /// Catat/update riwayat membaca saat buku dibuka
  static Future<void> recordBookOpen(BookModel book) async {
    final uid = _uid;
    final now = DateTime.now();
    final entry = ReadingHistoryModel(
      bookId: book.id,
      title: book.title,
      authors: book.authorsDisplay,
      thumbnail: book.bestCover,
      progress: 0.0,
      lastPage: 0,
      totalPages: book.pageCount,
      lastReadAt: now,
      addedAt: now,
    );

    if (uid != null) {
      // User authenticated: simpan ke Firestore
      final existing = await getBookHistory(book.id);

      if (existing != null) {
        // Update lastReadAt saja
        await _collection(uid).doc(book.id).update({
          'lastReadAt': Timestamp.fromDate(now),
        });
      } else {
        // Buat entri baru
        await _collection(uid).doc(book.id).set(entry.toFirestore());
      }
    } else {
      // User tidak authenticated: simpan ke local storage
      final existing = (await _getLocalHistory())[book.id];
      if (existing != null) {
        await _updateLocalHistoryEntry(existing.copyWith(lastReadAt: now));
      } else {
        await _updateLocalHistoryEntry(entry);
      }
      debugPrint(
          '[ReadingHistoryService] 💾 Recorded book open (local): ${book.id}');
    }
  }

  /// Update progress membaca
  static Future<void> updateProgress(
    String bookId, {
    required double progress,
    required int lastPage,
  }) async {
    final uid = _uid;
    final now = DateTime.now();

    if (uid != null) {
      // User authenticated: update di Firestore
      await _collection(uid).doc(bookId).update({
        'progress': progress.clamp(0.0, 1.0),
        'lastPage': lastPage,
        'lastReadAt': Timestamp.fromDate(now),
      });
    } else {
      // User tidak authenticated: update di local storage
      final history = await _getLocalHistory();
      final existing = history[bookId];
      if (existing != null) {
        await _updateLocalHistoryEntry(existing.copyWith(
          progress: progress.clamp(0.0, 1.0),
          lastPage: lastPage,
          lastReadAt: now,
        ));
      }
    }
  }

  /// Tandai buku selesai dibaca
  static Future<void> markAsFinished(String bookId) async {
    final uid = _uid;
    final now = DateTime.now();

    if (uid != null) {
      // User authenticated: update di Firestore
      await _collection(uid).doc(bookId).update({
        'progress': 1.0,
        'lastReadAt': Timestamp.fromDate(now),
      });
    } else {
      // User tidak authenticated: update di local storage
      final history = await _getLocalHistory();
      final existing = history[bookId];
      if (existing != null) {
        await _updateLocalHistoryEntry(existing.copyWith(
          progress: 1.0,
          lastReadAt: now,
        ));
      }
    }
  }

  /// Hapus satu entri history
  static Future<void> deleteHistory(String bookId) async {
    final uid = _uid;
    if (uid != null) {
      // User authenticated: hapus dari Firestore
      await _collection(uid).doc(bookId).delete();
    } else {
      // User tidak authenticated: hapus dari local storage
      await _deleteLocalHistoryEntry(bookId);
    }
  }

  /// Hapus semua riwayat
  static Future<void> clearAllHistory() async {
    final uid = _uid;
    if (uid != null) {
      // User authenticated: hapus dari Firestore
      final snap = await _collection(uid).get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } else {
      // User tidak authenticated: hapus dari local storage
      await _saveLocalHistory({});
    }
  }
}
