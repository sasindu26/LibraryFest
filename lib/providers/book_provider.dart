import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isAdmin = false;

  List<Book> get books => _filteredBooks.isEmpty && _searchQuery.isEmpty
      ? _books
      : _filteredBooks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isAdmin => _isAdmin;

  BookProvider() {
    checkAdminStatus();
    fetchBooks();
  }

  Future<void> checkAdminStatus() async {
    // In a real app, check user role from Firestore
    // For now, you can set this based on user email or a user document
    _isAdmin = false; // Set to true for admin users
    notifyListeners();
  }

  Future<void> setAdminStatus(bool status) async {
    _isAdmin = status;
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('books')
          .orderBy('createdAt', descending: true)
          .get();

      _books = querySnapshot.docs
          .map((doc) => Book.fromMap(doc.id, doc.data()))
          .toList();

      _filteredBooks = _books;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching books: $e');
    }
  }

  Future<void> addBook(Book book) async {
    try {
      await _firestore.collection('books').add(book.toMap());
      await fetchBooks();
    } catch (e) {
      debugPrint('Error adding book: $e');
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _firestore.collection('books').doc(book.id).update(book.toMap());
      await fetchBooks();
    } catch (e) {
      debugPrint('Error updating book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
      await fetchBooks();
    } catch (e) {
      debugPrint('Error deleting book: $e');
      rethrow;
    }
  }

  Future<bool> borrowBook(String bookId, String userId) async {
    try {
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      
      if (!bookDoc.exists) {
        return false;
      }

      final book = Book.fromMap(bookId, bookDoc.data()!);
      
      if (book.availableCopies <= 0) {
        return false;
      }

      // Create borrowed book record
      final dueDate = DateTime.now().add(const Duration(days: 14));
      final borrowedBook = BorrowedBook(
        id: '',
        bookId: bookId,
        userId: userId,
        bookTitle: book.title,
        bookAuthor: book.author,
        borrowedDate: DateTime.now(),
        dueDate: dueDate,
        isReturned: false,
      );

      await _firestore.collection('borrowedBooks').add(borrowedBook.toMap());

      // Update book availability
      await _firestore.collection('books').doc(bookId).update({
        'availableCopies': book.availableCopies - 1,
      });

      await fetchBooks();
      return true;
    } catch (e) {
      debugPrint('Error borrowing book: $e');
      return false;
    }
  }

  Future<bool> returnBook(String borrowedBookId, String bookId) async {
    try {
      // Update borrowed book record
      await _firestore.collection('borrowedBooks').doc(borrowedBookId).update({
        'isReturned': true,
        'returnDate': DateTime.now().toIso8601String(),
      });

      // Get current book
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (bookDoc.exists) {
        final book = Book.fromMap(bookId, bookDoc.data()!);
        await _firestore.collection('books').doc(bookId).update({
          'availableCopies': book.availableCopies + 1,
        });
      }

      await fetchBooks();
      return true;
    } catch (e) {
      debugPrint('Error returning book: $e');
      return false;
    }
  }

  Future<List<BorrowedBook>> getBorrowedBooks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('borrowedBooks')
          .where('userId', isEqualTo: userId)
          .where('isReturned', isEqualTo: false)
          .orderBy('borrowedDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BorrowedBook.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching borrowed books: $e');
      return [];
    }
  }

  void searchBooks(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredBooks = _books;
    } else {
      _filteredBooks = _books.where((book) {
        final titleMatch = book.title.toLowerCase().contains(query.toLowerCase());
        final authorMatch = book.author.toLowerCase().contains(query.toLowerCase());
        final isbnMatch = book.isbn.toLowerCase().contains(query.toLowerCase());
        return titleMatch || authorMatch || isbnMatch;
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredBooks = _books;
    notifyListeners();
  }
}


