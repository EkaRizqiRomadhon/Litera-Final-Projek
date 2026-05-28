import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/admin_service.dart';
import '../../widgets/book_cover_widget.dart';
import 'book_form_page.dart';

class BookManagementPage extends StatelessWidget {
  const BookManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF818CF8),
          surface: Color(0xFF1E293B),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library Management', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
        ),
        body: StreamBuilder<List<BookModel>>(
          stream: AdminService.watchAllBooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFEF4444))));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No books in database.', style: TextStyle(color: Color(0xFF64748B))));
            }

            final books = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100), // Extra bottom padding for navbar
              physics: const BouncingScrollPhysics(),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      BookCoverWidget(
                        imageUrl: book.thumbnail ?? '',
                        width: 55,
                        height: 80,
                        borderRadius: 10,
                        fallbackColor: const Color(0xFF0F172A),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.authorsDisplay,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                book.categories.isNotEmpty ? book.categories.first : 'Uncategorized',
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_document, color: Color(0xFF38BDF8), size: 22),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BookFormPage(book: book)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                            onPressed: () => _confirmDelete(context, book),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookFormPage()),
            ),
            backgroundColor: const Color(0xFF38BDF8),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book?'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AdminService.deleteBook(book.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Book deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
