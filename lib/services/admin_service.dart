import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import 'local_book_service.dart';

class AdminService {
  static final _firestore = FirebaseFirestore.instance;
  static final CollectionReference _booksCol = _firestore.collection('books');

  /// Stream all books for the dashboard (includes local books)
  static Stream<List<BookModel>> watchAllBooks() {
    return _booksCol.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      final firestoreBooks = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      return [...LocalBookService.localBooks, ...firestoreBooks];
    });
  }

  /// Get total books count once
  static Future<int> getBooksCount() async {
    final snapshot = await _booksCol.count().get();
    final firestoreCount = snapshot.count ?? 0;
    return firestoreCount + LocalBookService.localBooks.length;
  }

  /// Get recent books (includes local books)
  static Future<List<BookModel>> getRecentBooks({int limit = 5}) async {
    final snapshot = await _booksCol.orderBy('createdAt', descending: true).limit(limit).get();
    final firestoreBooks = snapshot.docs
        .map((doc) => BookModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    final allBooks = [...LocalBookService.localBooks, ...firestoreBooks];
    return allBooks.take(limit).toList();
  }

  /// Add a new book
  static Future<void> addBook(BookModel book) async {
    final docRef = _booksCol.doc();
    // Create a new model with the generated ID
    final bookWithId = BookModel(
      id: docRef.id,
      title: book.title,
      authors: book.authors,
      categories: book.categories,
      thumbnail: book.thumbnail,
      epubDownloadLink: book.epubDownloadLink,
      description: book.description,
      subtitle: book.subtitle,
      publisher: book.publisher,
      publishedDate: book.publishedDate,
      pageCount: book.pageCount,
      language: book.language,
      previewLink: book.previewLink,
      infoLink: book.infoLink,
      isEbook: book.isEbook,
    );
    
    await docRef.set(bookWithId.toFirestore());
  }

  /// Update an existing book
  static Future<void> updateBook(BookModel book) async {
    if (book.id.isEmpty) throw Exception("Book ID cannot be empty for updates");
    await _booksCol.doc(book.id).set(book.toFirestore(), SetOptions(merge: true));
  }

  /// Delete a book
  static Future<void> deleteBook(String bookId) async {
    await _booksCol.doc(bookId).delete();
  }
}
