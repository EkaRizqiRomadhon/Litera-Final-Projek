import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../pages/book_reader_page.dart';
import '../pages/reader_page.dart';
import 'reading_history_service.dart';
import 'cache_service.dart';
import 'local_book_service.dart';


class BookService {
  /// Mendapatkan link yang bisa dibaca (PDF atau EPUB)
  /// Prioritas: PDF > EPUB
  static String? getReadableLink(BookModel book) {
    if (book.pdfDownloadLink != null && book.pdfDownloadLink!.isNotEmpty) {
      return book.pdfDownloadLink;
    }
    if (book.epubDownloadLink != null && book.epubDownloadLink!.isNotEmpty) {
      return book.epubDownloadLink;
    }
    return null;
  }

  /// Mengecek apakah buku bisa dibaca di dalam aplikasi
  static bool isReadable(BookModel book) {
    return getReadableLink(book) != null || book.isbn.isNotEmpty || book.title.isNotEmpty;
  }

  /// Menangani aksi baca buku
  static Future<void> openBook(BuildContext context, BookModel book) async {
    final pdfUrl = book.pdfDownloadLink;

    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buku ini tidak memiliki format digital PDF yang valid.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    debugPrint('[BookService] 📖 Opening PDF reader: $pdfUrl');
    _navigateToNativeReader(
      context, 
      book, 
      remoteUrl: pdfUrl, 
      isPdf: true,
    );
  }

  /// Helper untuk navigasi ke native reader
  static void _navigateToNativeReader(
    BuildContext context, 
    BookModel book, 
    {String? localPath, String? remoteUrl, bool isPdf = true}
  ) {
    // Update history
    ReadingHistoryService.recordBookOpen(book);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookReaderPage(
          book: book,
          localPath: localPath,
          remoteUrl: remoteUrl,
          isPdf: isPdf,
        ),
      ),
    );
  }

  /// Membuka buku berdasarkan ID (untuk riwayat/bookmark)
  static Future<void> openBookById(BuildContext context, String bookId) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final book = LocalBookService.localBooks.firstWhere((b) => b.id == bookId);
      if (!context.mounted) return;
      Navigator.pop(context); // Tutup loading

      await openBook(context, book);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: Buku tidak ditemukan')),
        );
      }
    }
  }
}
