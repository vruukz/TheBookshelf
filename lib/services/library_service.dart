import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class LibraryService extends ChangeNotifier {
  static const _storageKey = 'bookvault_library';

  List<Book> _books = [];
  bool _isLoading = false;
  String _searchQuery = '';
  ReadingStatus? _filterStatus;
  BookFormat? _filterFormat;
  String _sortBy = 'recent'; // 'recent', 'title', 'author', 'progress'

  List<Book> get allBooks => _books;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ReadingStatus? get filterStatus => _filterStatus;
  BookFormat? get filterFormat => _filterFormat;
  String get sortBy => _sortBy;

  List<Book> get filteredBooks {
    var result = _books.where((book) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!book.title.toLowerCase().contains(q) &&
            !book.author.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_filterStatus != null && book.status != _filterStatus) return false;
      if (_filterFormat != null && book.format != _filterFormat) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'title':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        result.sort((a, b) => a.author.compareTo(b.author));
        break;
      case 'progress':
        result.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      default: // 'recent'
        result.sort((a, b) {
          final aDate = a.lastReadAt ?? a.addedAt;
          final bDate = b.lastReadAt ?? b.addedAt;
          return bDate.compareTo(aDate);
        });
    }
    return result;
  }

  List<Book> get currentlyReading =>
      _books.where((b) => b.status == ReadingStatus.reading).toList()
        ..sort((a, b) => (b.lastReadAt ?? b.addedAt).compareTo(a.lastReadAt ?? a.addedAt));

  List<Book> get recentlyAdded =>
      [..._books]..sort((a, b) => b.addedAt.compareTo(a.addedAt));

  int get totalBooks => _books.length;
  int get booksRead => _books.where((b) => b.status == ReadingStatus.finished).length;
  int get booksReading => _books.where((b) => b.status == ReadingStatus.reading).length;
  int get totalReadingMinutes => _books.fold(0, (sum, b) => sum + b.readingTimeMinutes);

  Future<void> loadLibrary() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _books = jsonList.map((j) => Book.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Error loading library: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveLibrary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_books.map((b) => b.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      debugPrint('Error saving library: $e');
    }
  }

  Future<void> addBook(Book book) async {
    _books.add(book);
    await _saveLibrary();
    notifyListeners();
  }

  Future<void> updateBook(Book book) async {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
      await _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> removeBook(String bookId) async {
    _books.removeWhere((b) => b.id == bookId);
    await _saveLibrary();
    notifyListeners();
  }

  Future<void> updateProgress(String bookId, int page) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final book = _books[index];
      _books[index] = book.copyWith(
        currentPage: page,
        lastReadAt: DateTime.now(),
        status: page >= book.totalPages && book.totalPages > 0
            ? ReadingStatus.finished
            : page > 0
                ? ReadingStatus.reading
                : book.status,
      );
      await _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> addBookmark(String bookId, Bookmark bookmark) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final book = _books[index];
      final bookmarks = [...book.bookmarks, bookmark];
      _books[index] = book.copyWith(bookmarks: bookmarks);
      await _saveLibrary();
      notifyListeners();
    }
  }

  Future<void> removeBookmark(String bookId, String bookmarkId) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final book = _books[index];
      final bookmarks = book.bookmarks.where((b) => b.id != bookmarkId).toList();
      _books[index] = book.copyWith(bookmarks: bookmarks);
      await _saveLibrary();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(ReadingStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterFormat(BookFormat? format) {
    _filterFormat = format;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterFormat = null;
    notifyListeners();
  }

  // Demo data for testing
  
}
