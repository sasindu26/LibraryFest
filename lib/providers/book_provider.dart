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

      // Create borrowed book request with pending status
      final dueDate = DateTime.now().add(const Duration(days: 14));
      final borrowedBook = BorrowedBook(
        id: '',
        bookId: bookId,
        userId: userId,
        bookTitle: book.title,
        bookAuthor: book.author,
        coverUrl: book.coverUrl,
        borrowedDate: DateTime.now(),
        dueDate: dueDate,
        isReturned: false,
        status: 'pending', // Requires admin approval
      );

      await _firestore.collection('borrowedBooks').add(borrowedBook.toMap());

      // Don't update book availability until approved
      // await _firestore.collection('books').doc(bookId).update({
      //   'availableCopies': book.availableCopies - 1,
      // });

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
      // Get both pending and approved books (not returned, not rejected)
      final querySnapshot = await _firestore
          .collection('borrowedBooks')
          .where('userId', isEqualTo: userId)
          .where('isReturned', isEqualTo: false)
          .get();

      // Filter for approved and pending books only (exclude rejected), sort in memory
      final books = querySnapshot.docs
          .map((doc) => BorrowedBook.fromMap(doc.id, doc.data()))
          .where((book) => book.status == 'approved' || book.status == 'pending')
          .toList();
      
      books.sort((a, b) => b.borrowedDate.compareTo(a.borrowedDate));
      
      return books;
    } catch (e) {
      debugPrint('Error fetching borrowed books: $e');
      return [];
    }
  }

  // Stream version for real-time updates - ONLY APPROVED books
  Stream<List<BorrowedBook>> getBorrowedBooksStream(String userId) {
    return _firestore
        .collection('borrowedBooks')
        .where('userId', isEqualTo: userId)
        .where('isReturned', isEqualTo: false)
        .where('status', isEqualTo: 'approved') // ONLY approved books
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs
          .map((doc) => BorrowedBook.fromMap(doc.id, doc.data()))
          .toList();
      
      books.sort((a, b) => b.borrowedDate.compareTo(a.borrowedDate));
      return books;
    });
  }

  // Stream for ALL borrowed books including pending (for admin or full view)
  Stream<List<BorrowedBook>> getAllBorrowedBooksStream(String userId) {
    return _firestore
        .collection('borrowedBooks')
        .where('userId', isEqualTo: userId)
        .where('isReturned', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs
          .map((doc) => BorrowedBook.fromMap(doc.id, doc.data()))
          .toList();
      
      books.sort((a, b) => b.borrowedDate.compareTo(a.borrowedDate));
      return books;
    });
  }

  Future<List<BorrowedBook>> getPendingBorrowRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('borrowedBooks')
          .where('status', isEqualTo: 'pending')
          .get();

      // Sort in memory instead of using orderBy to avoid index requirement
      final requests = querySnapshot.docs
          .map((doc) => BorrowedBook.fromMap(doc.id, doc.data()))
          .toList();
      
      requests.sort((a, b) => b.borrowedDate.compareTo(a.borrowedDate));
      
      return requests;
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
      return [];
    }
  }

  // Stream version for real-time updates in admin panel
  Stream<List<BorrowedBook>> getPendingBorrowRequestsStream() {
    return _firestore
        .collection('borrowedBooks')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => BorrowedBook.fromMap(doc.id, doc.data()))
          .toList();
      
      requests.sort((a, b) => b.borrowedDate.compareTo(a.borrowedDate));
      return requests;
    });
  }

  Future<bool> approveBorrowRequest(String borrowedBookId, String bookId) async {
    try {
      // Update borrow request status
      await _firestore.collection('borrowedBooks').doc(borrowedBookId).update({
        'status': 'approved',
      });

      // Update book availability
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (bookDoc.exists) {
        final book = Book.fromMap(bookId, bookDoc.data()!);
        await _firestore.collection('books').doc(bookId).update({
          'availableCopies': book.availableCopies - 1,
        });
      }

      await fetchBooks();
      return true;
    } catch (e) {
      debugPrint('Error approving borrow request: $e');
      return false;
    }
  }

  Future<bool> rejectBorrowRequest(String borrowedBookId) async {
    try {
      await _firestore.collection('borrowedBooks').doc(borrowedBookId).update({
        'status': 'rejected',
      });
      return true;
    } catch (e) {
      debugPrint('Error rejecting borrow request: $e');
      return false;
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


