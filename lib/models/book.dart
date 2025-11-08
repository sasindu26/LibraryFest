import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String description;
  final int availableCopies;
  final int totalCopies;
  final String? coverUrl;
  final DateTime createdAt;
  final String category;
  final double rating;
  final int publishedYear;
  final String? fullContent; // Full book text for reading

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.description,
    required this.availableCopies,
    required this.totalCopies,
    this.coverUrl,
    required this.createdAt,
    this.category = 'General',
    this.rating = 4.0,
    this.publishedYear = 2020,
    this.fullContent,
  });

  // Helper getter for availability
  bool get available => availableCopies > 0;

  // Convert Book to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'description': description,
      'availableCopies': availableCopies,
      'totalCopies': totalCopies,
      'coverUrl': coverUrl,
      'category': category,
      'rating': rating,
      'publishedYear': publishedYear,
      'fullContent': fullContent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Book from Firestore document
  factory Book.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseCreatedAt() {
      final createdAtField = map['createdAt'];
      if (createdAtField == null) return DateTime.now();
      
      // Handle Firestore Timestamp
      if (createdAtField is Timestamp) {
        return createdAtField.toDate();
      }
      // Handle ISO8601 String
      if (createdAtField is String) {
        return DateTime.parse(createdAtField);
      }
      return DateTime.now();
    }

    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      isbn: map['isbn'] ?? '',
      description: map['description'] ?? '',
      availableCopies: map['availableCopies'] ?? 0,
      totalCopies: map['totalCopies'] ?? 0,
      coverUrl: map['coverUrl'],
      category: map['category'] ?? 'General',
      rating: (map['rating'] ?? 4.0).toDouble(),
      publishedYear: map['publishedYear'] ?? 2020,
      fullContent: map['fullContent'],
      createdAt: parseCreatedAt(),
    );
  }

  // Copy with method for updating
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? description,
    int? availableCopies,
    int? totalCopies,
    String? coverUrl,
    DateTime? createdAt,
    String? category,
    double? rating,
    int? publishedYear,
    String? fullContent,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      description: description ?? this.description,
      availableCopies: availableCopies ?? this.availableCopies,
      totalCopies: totalCopies ?? this.totalCopies,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      publishedYear: publishedYear ?? this.publishedYear,
      fullContent: fullContent ?? this.fullContent,
    );
  }
}

class BorrowedBook {
  final String id;
  final String bookId;
  final String userId;
  final String bookTitle;
  final String bookAuthor;
  final String? coverUrl;
  final DateTime borrowedDate;
  final DateTime? returnDate;
  final DateTime dueDate;
  final bool isReturned;
  final String status; // 'pending', 'approved', 'rejected'

  BorrowedBook({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.bookTitle,
    required this.bookAuthor,
    this.coverUrl,
    required this.borrowedDate,
    this.returnDate,
    required this.dueDate,
    required this.isReturned,
    this.status = 'approved', // default for backward compatibility
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'coverUrl': coverUrl,
      'borrowedDate': borrowedDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'isReturned': isReturned,
      'status': status,
    };
  }

  factory BorrowedBook.fromMap(String id, Map<String, dynamic> map) {
    return BorrowedBook(
      id: id,
      bookId: map['bookId'] ?? '',
      userId: map['userId'] ?? '',
      bookTitle: map['bookTitle'] ?? 'Unknown Book',
      bookAuthor: map['bookAuthor'] ?? 'Unknown Author',
      coverUrl: map['coverUrl'],
      borrowedDate: DateTime.parse(map['borrowedDate']),
      returnDate: map['returnDate'] != null
          ? DateTime.parse(map['returnDate'])
          : null,
      dueDate: DateTime.parse(map['dueDate']),
      isReturned: map['isReturned'] ?? false,
      status: map['status'] ?? 'approved',
    );
  }
}


