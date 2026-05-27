import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';

/// Service to handle resolving readable ebook sources from Google Books,
/// Open Library, and Internet Archive.
class EbookSourceService {
  static const String _userAgent = 'LiteraEbookApp/1.0 (contact: ekarizqi.dev@gmail.com)';

  /// Mendapatkan list ia (Internet Archive) ID untuk buku
  static Future<List<String>> _fetchIaIds(BookModel book) async {
    final List<String> iaIds = [];

    // 1. Coba cari dengan ISBN jika tersedia
    if (book.isbn.isNotEmpty) {
      try {
        final isbnClean = book.isbn.replaceAll(RegExp(r'[^0-9X]'), '');
        final url = 'https://openlibrary.org/api/books?bibkeys=ISBN:$isbnClean&jscmd=details&format=json';
        debugPrint('[EbookSourceService] 🔍 Querying Open Library by ISBN: $isbnClean');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': _userAgent},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final key = 'ISBN:$isbnClean';
          if (data.containsKey(key)) {
            final bookData = data[key] as Map<String, dynamic>;
            final details = bookData['details'] as Map<String, dynamic>? ?? {};
            final ia = details['ia'] as List<dynamic>? ?? [];
            for (var id in ia) {
              if (id is String && id.isNotEmpty) {
                iaIds.add(id);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[EbookSourceService] ⚠️ Open Library ISBN query error: $e');
      }
    }

    // 2. Jika tidak ada ISBN atau tidak ada iaIds, coba search dengan Title dan Author
    if (iaIds.isEmpty) {
      try {
        final title = book.title;
        final author = book.authorsDisplay;
        
        // Clean title and author to avoid special char issues in search query
        final cleanTitle = title.replaceAll(RegExp(r'[^\w\s]'), ' ');
        final cleanAuthor = author != 'Penulis Tidak Diketahui' 
            ? author.replaceAll(RegExp(r'[^\w\s]'), ' ') 
            : '';
            
        String query = 'title:($cleanTitle)';
        if (cleanAuthor.isNotEmpty) {
          query += ' AND author:($cleanAuthor)';
        }
        
        final url = 'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=3&fields=ia,title';
        debugPrint('[EbookSourceService] 🔍 Querying Open Library search: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': _userAgent},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final docs = data['docs'] as List<dynamic>? ?? [];
          for (var doc in docs) {
            if (doc is Map<String, dynamic>) {
              final ia = doc['ia'] as List<dynamic>? ?? [];
              for (var id in ia) {
                if (id is String && id.isNotEmpty && !iaIds.contains(id)) {
                  iaIds.add(id);
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[EbookSourceService] ⚠️ Open Library Search query error: $e');
      }
    }

    return iaIds;
  }

  /// Cek validitas URL dengan HEAD request
  static Future<bool> _isUrlValid(String url) async {
    try {
      final response = await http.head(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      // Jika HEAD request gagal atau tidak didukung, coba GET request minimalis
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': _userAgent,
            'Range': 'bytes=0-0', // Request only first byte to save bandwidth
          },
        ).timeout(const Duration(seconds: 3));
        return response.statusCode == 200 || response.statusCode == 206;
      } catch (_) {
        return false;
      }
    }
  }

  /// Resolving URL EPUB dan PDF terbaik untuk buku ini
  static Future<ResolvedSources> resolveSources(BookModel book) async {
    // 1. Google Books PDF (prioritas 1)
    if (book.pdfDownloadLink != null && book.pdfDownloadLink!.isNotEmpty) {
      debugPrint('[EbookSourceService] Found Google Books PDF');
      if (await _isUrlValid(book.pdfDownloadLink!)) {
        return ResolvedSources(
          pdfUrl: book.pdfDownloadLink,
          sourceType: 'Google Books PDF',
        );
      }
    }

    // 2. Google Books EPUB (prioritas 2)
    if (book.epubDownloadLink != null && book.epubDownloadLink!.isNotEmpty) {
      debugPrint('[EbookSourceService] Found Google Books EPUB');
      if (await _isUrlValid(book.epubDownloadLink!)) {
        return ResolvedSources(
          epubUrl: book.epubDownloadLink,
          sourceType: 'Google Books EPUB',
        );
      }
    }

    // Cari Internet Archive IDs
    final iaIds = await _fetchIaIds(book);
    debugPrint('[EbookSourceService] Resolved IA IDs: $iaIds');

    // 3 & 4. Internet Archive EPUB dan PDF - check semua URL secara parallel
    if (iaIds.isNotEmpty) {
      // Build daftar URL untuk checking (EPUB first, then PDF)
      final urlChecks = <Future<({String url, String type})>>[
        // EPUB URLs (prioritas lebih tinggi)
        for (var iaId in iaIds)
          _checkUrl('https://archive.org/download/$iaId/$iaId.epub', 'EPUB'),
        // PDF URLs (prioritas lebih rendah)
        for (var iaId in iaIds)
          _checkUrl('https://archive.org/download/$iaId/$iaId.pdf', 'PDF'),
      ];

      try {
        final results = await Future.wait(urlChecks, eagerError: false);
        
        // Cari hasil yang valid dengan memprioritaskan EPUB
        for (final result in results) {
          if (result.url.isNotEmpty) {
            final isPdf = result.type == 'PDF';
            debugPrint('[EbookSourceService] Found Internet Archive ${result.type}: ${result.url}');
            if (isPdf) {
              return ResolvedSources(
                pdfUrl: result.url,
                sourceType: 'Internet Archive PDF',
              );
            } else {
              return ResolvedSources(
                epubUrl: result.url,
                sourceType: 'Internet Archive EPUB',
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[EbookSourceService] ⚠️ Error during parallel URL check: $e');
      }
    }

    // 5. webReaderLink (prioritas 5)
    if (book.hasWebReader) {
      return ResolvedSources(
        webUrl: book.webReaderLink,
        sourceType: 'Web Reader',
      );
    }

    // 6. previewLink (prioritas 6)
    if (book.hasPreview) {
      return ResolvedSources(
        webUrl: book.previewLink,
        sourceType: 'Preview',
      );
    }

    return ResolvedSources(sourceType: 'None');
  }

  /// Helper untuk check URL secara parallel dan return URL jika valid, empty string jika tidak
  static Future<({String url, String type})> _checkUrl(String url, String type) async {
    try {
      final isValid = await _isUrlValid(url);
      if (isValid) {
        return (url: url, type: type);
      }
    } catch (e) {
      debugPrint('[EbookSourceService] ⚠️ Error checking URL $url: $e');
    }
    return (url: '', type: type);
  }
}

class ResolvedSources {
  final String? pdfUrl;
  final String? epubUrl;
  final String? webUrl;
  final String sourceType;

  ResolvedSources({
    this.pdfUrl,
    this.epubUrl,
    this.webUrl,
    required this.sourceType,
  });

  bool get isNative => pdfUrl != null || epubUrl != null;
  bool get isWeb => webUrl != null;
}
