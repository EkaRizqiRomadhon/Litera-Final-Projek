import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;


/// Service untuk menangani caching ebook secara lokal
class CacheService {
  static final Dio _dio = Dio();

  /// Mendapatkan direktori penyimpanan aplikasi
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Mendapatkan referensi file lokal berdasarkan ID dan ekstensi
  static Future<File> _getLocalFile(String bookId, String extension) async {
    final path = await _localPath;
    final dir = Directory('$path/ebooks');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$bookId.$extension');
  }

  /// Mengecek apakah buku sudah tersimpan di cache
  static Future<File?> getCachedBook(String bookId) async {
    try {
      final path = await _localPath;
      final dir = Directory('$path/ebooks');
      if (!await dir.exists()) return null;

      // Cek PDF
      final pdf = File('${dir.path}/$bookId.pdf');
      if (await pdf.exists()) return pdf;

      // Cek EPUB
      final epub = File('${dir.path}/$bookId.epub');
      if (await epub.exists()) return epub;

      return null;
    } catch (e) {
      debugPrint('[CacheService] ⚠️ Error checking cache: $e');
      return null;
    }
  }

  /// Download buku dan simpan ke cache
  static Future<File> downloadBook(
    String bookId, 
    String url, 
    String extension,
    {ProgressCallback? onProgress}
  ) async {
    final file = await _getLocalFile(bookId, extension);
    
    try {
      debugPrint('[CacheService] 📥 Downloading $bookId from $url');
      await _dio.download(
        url, 
        file.path,
        onReceiveProgress: onProgress,
      );
      debugPrint('[CacheService] ✅ Saved to ${file.path}');
      return file;
    } catch (e) {
      debugPrint('[CacheService] ❌ Download error: $e');
      // Hapus file jika gagal sebagian
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  /// Ekstrak buku dari assets ke local cache jika belum ada
  static Future<File> extractAssetBook(String bookId, String assetPath) async {
    final file = await _getLocalFile(bookId, 'pdf');
    if (await file.exists()) {
      return file;
    }
    
    try {
      debugPrint('[CacheService] 📦 Extracting asset book $bookId from $assetPath');
      final byteData = await rootBundle.load(assetPath);
      final buffer = byteData.buffer;
      await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        flush: true,
      );
      debugPrint('[CacheService] ✅ Extracted asset to ${file.path}');
      return file;
    } catch (e) {
      debugPrint('[CacheService] ❌ Asset extraction error: $e');
      rethrow;
    }
  }

  /// Hapus file cache yang sudah lama (default: lebih dari 30 hari)
  /// Mengembalikan jumlah file yang dihapus
  static Future<int> cleanOldCache({Duration maxAge = const Duration(days: 30)}) async {
    try {
      final path = await _localPath;
      final dir = Directory('$path/ebooks');
      if (!await dir.exists()) return 0;

      int deletedCount = 0;
      final now = DateTime.now();
      final cutoffTime = now.subtract(maxAge);

      for (var entity in dir.listSync()) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            // Jika file terakhir dimodifikasi sebelum cutoffTime, hapus
            if (stat.modified.isBefore(cutoffTime)) {
              await entity.delete();
              debugPrint('[CacheService] 🗑️ Deleted old cache: ${entity.path}');
              deletedCount++;
            }
          } catch (e) {
            debugPrint('[CacheService] ⚠️ Error checking/deleting file: $e');
          }
        }
      }

      debugPrint('[CacheService] ✅ Cleaned $deletedCount old cache file(s)');
      return deletedCount;
    } catch (e) {
      debugPrint('[CacheService] ⚠️ Error cleaning old cache: $e');
      return 0;
    }
  }

  /// Mendapatkan total ukuran cache folder dalam bytes
  static Future<int> getCacheSize() async {
    try {
      final path = await _localPath;
      final dir = Directory('$path/ebooks');
      if (!await dir.exists()) return 0;

      int totalSize = 0;
      for (var entity in dir.listSync(recursive: false, followLinks: false)) {
        if (entity is File) {
          try {
            final size = await entity.length();
            totalSize += size;
          } catch (e) {
            debugPrint('[CacheService] ⚠️ Error getting file size: $e');
          }
        }
      }

      debugPrint('[CacheService] 📊 Cache size: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB');
      return totalSize;
    } catch (e) {
      debugPrint('[CacheService] ⚠️ Error calculating cache size: $e');
      return 0;
    }
  }

  /// Hapus semua cache ebook
  static Future<void> clearCache() async {
    try {
      final path = await _localPath;
      final dir = Directory('$path/ebooks');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[CacheService] ⚠️ Error clearing cache: $e');
    }
  }
}
