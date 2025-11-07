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
  });

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
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Book from Firestore document
  factory Book.fromMap(String id, Map<String, dynamic> map) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      isbn: map['isbn'] ?? '',
      description: map['description'] ?? '',
      availableCopies: map['availableCopies'] ?? 0,
      totalCopies: map['totalCopies'] ?? 0,
      coverUrl: map['coverUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
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
    );
  }
}

class BorrowedBook {
  final String id;
  final String bookId;
  final String userId;
  final String bookTitle;
  final String bookAuthor;
  final DateTime borrowedDate;
  final DateTime? returnDate;
  final DateTime dueDate;
  final bool isReturned;

  BorrowedBook({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.borrowedDate,
    this.returnDate,
    required this.dueDate,
    required this.isReturned,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'borrowedDate': borrowedDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'isReturned': isReturned,
    };
  }

  factory BorrowedBook.fromMap(String id, Map<String, dynamic> map) {
    return BorrowedBook(
      id: id,
      bookId: map['bookId'] ?? '',
      userId: map['userId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      bookAuthor: map['bookAuthor'] ?? '',
      borrowedDate: DateTime.parse(map['borrowedDate']),
      returnDate: map['returnDate'] != null
          ? DateTime.parse(map['returnDate'])
          : null,
      dueDate: DateTime.parse(map['dueDate']),
      isReturned: map['isReturned'] ?? false,
    );
  }
}


