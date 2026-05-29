import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/local_book_service.dart';

/// Load state enum shared across all provider sections.
enum LoadState { idle, loading, loaded, error }

/// Provider for all Google Books API data used across the app.
class BookProvider extends ChangeNotifier {
  // ── Dashboard ────────────────────────────────────────────────────────────────
  List<BookModel> _popularBooks = [];
  List<BookModel> _newestBooks = [];
  List<BookModel> _recommendedBooks = [];
  List<BookModel> _trendingBooks = [];

  LoadState _dashboardState = LoadState.idle;
  String _dashboardError = '';

  // ── Category / Explore ───────────────────────────────────────────────────────
  List<BookModel> _categoryBooks = [];
  LoadState _categoryState = LoadState.idle;
  String _categoryError = '';
  String _selectedCategory = 'Semua';
  bool _categoryHasMore = true;
  int _categoryPage = 0;

  // ── Search ───────────────────────────────────────────────────────────────────
  List<BookModel> _searchResults = [];
  LoadState _searchState = LoadState.idle;
  String _searchError = '';
  String _lastQuery = '';
  bool _searchHasMore = true;
  int _searchPage = 0;

  // ── Related books (detail page) ───────────────────────────────────────────────
  List<BookModel> _relatedBooks = [];
  LoadState _relatedState = LoadState.idle;
  String _relatedBookId = ''; // Cache key to avoid redundant loads

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<BookModel> get popularBooks => _popularBooks;
  List<BookModel> get newestBooks => _newestBooks;
  List<BookModel> get recommendedBooks => _recommendedBooks;
  List<BookModel> get trendingBooks => _trendingBooks;
  LoadState get dashboardState => _dashboardState;
  String get dashboardError => _dashboardError;
  bool get isDashboardLoading => _dashboardState == LoadState.loading;

  List<BookModel> get categoryBooks => _categoryBooks;
  LoadState get categoryState => _categoryState;
  String get categoryError => _categoryError;
  String get selectedCategory => _selectedCategory;
  bool get isCategoryLoading => _categoryState == LoadState.loading;
  bool get categoryHasMore => _categoryHasMore;

  List<BookModel> get searchResults => _searchResults;
  LoadState get searchState => _searchState;
  String get searchError => _searchError;
  bool get isSearchLoading => _searchState == LoadState.loading;
  bool get hasSearchResults => _searchResults.isNotEmpty;
  bool get searchHasMore => _searchHasMore;

  List<BookModel> get relatedBooks => _relatedBooks;
  LoadState get relatedState => _relatedState;

  // ── Dashboard ─────────────────────────────────────────────────────────────────

  Future<void> loadDashboard({bool force = false}) async {
    if (_dashboardState == LoadState.loading) return;
    if (_dashboardState == LoadState.loaded && !force) return;

    _dashboardState = LoadState.loading;
    _dashboardError = '';
    notifyListeners();

    try {
      final local = LocalBookService.localBooks;
      
      _popularBooks = local.toList();
      _newestBooks = local.toList();
      _recommendedBooks = local.toList();
      _trendingBooks = local.toList();

      final anyLoaded = _popularBooks.isNotEmpty ||
          _newestBooks.isNotEmpty ||
          _recommendedBooks.isNotEmpty ||
          _trendingBooks.isNotEmpty;

      if (!anyLoaded) {
        _dashboardState = LoadState.error;
        _dashboardError = 'errorNoBooksLoaded';
      } else {
        _dashboardState = LoadState.loaded;
      }
    } catch (e) {
      _dashboardState = LoadState.error;
      _dashboardError = _friendlyError(e);
    }

    notifyListeners();
  }

  // ── Category ──────────────────────────────────────────────────────────────────

  Future<void> loadCategory(String category, String apiQuery) async {
    if (_selectedCategory == category && _categoryState == LoadState.loaded) return;

    _selectedCategory = category;
    _categoryState = LoadState.loading;
    _categoryError = '';
    _categoryBooks = [];
    _categoryPage = 0;
    _categoryHasMore = false;
    notifyListeners();

    try {
      _categoryBooks = LocalBookService.getBooksByCategory(category);
      _categoryState = _categoryBooks.isEmpty ? LoadState.error : LoadState.loaded;
      if (_categoryBooks.isEmpty) _categoryError = 'errorNoBooks';
    } catch (e) {
      _categoryState = _categoryBooks.isEmpty ? LoadState.error : LoadState.loaded;
      _categoryError = _friendlyError(e);
    }

    notifyListeners();
  }

  /// Load next page for infinite scroll.
  Future<void> loadMoreCategory(String apiQuery) async {
    // Local data only, no more pages
  }

  // ── Search ────────────────────────────────────────────────────────────────────

  Future<void> searchBooks(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      clearSearch();
      return;
    }

    if (q == _lastQuery && _searchState == LoadState.loaded) return;

    _lastQuery = q;
    _searchState = LoadState.loading;
    _searchError = '';
    _searchPage = 0;
    _searchHasMore = false;
    notifyListeners();

    try {
      _searchResults = LocalBookService.searchBooks(q);
      _searchState = LoadState.loaded;
    } catch (e) {
      _searchState = LoadState.error;
      _searchError = _friendlyError(e);
    }

    notifyListeners();
  }

  Future<void> loadMoreSearch() async {
    // Local data only, no more pages
  }

  void clearSearch() {
    _searchResults = [];
    _searchState = LoadState.idle;
    _lastQuery = '';
    _searchError = '';
    _searchHasMore = true;
    _searchPage = 0;
    notifyListeners();
  }

  // ── Related ───────────────────────────────────────────────────────────────────

  Future<void> loadRelatedBooks(BookModel book) async {
    // Skip if already loaded for this book
    if (_relatedBookId == book.id && _relatedState == LoadState.loaded) return;
    _relatedBookId = book.id;
    _relatedBooks = [];
    _relatedState = LoadState.loading;
    notifyListeners();
    try {
      _relatedBooks = LocalBookService.localBooks
          .where((b) => b.id != book.id && b.categories.any((c) => book.categories.contains(c)))
          .take(6)
          .toList();
      _relatedState = LoadState.loaded;
    } catch (_) {
      _relatedState = LoadState.error;
    }
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────



  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Failed host lookup') || msg.contains('errorNoInternet')) {
      return 'errorNoInternet';
    }
    if (msg.contains('TimeoutException') || msg.contains('errorTimeout')) {
      return 'errorTimeout';
    }
    return 'errorGeneral';
  }
}
