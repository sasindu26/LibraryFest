import 'package:cloud_firestore/cloud_firestore.dart';

class SampleBooksData {
  static Future<void> addSampleBooks() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // Check if books already exist
    final booksSnapshot = await firestore.collection('books').limit(1).get();
    if (booksSnapshot.docs.isNotEmpty) {
      print('Books already exist, skipping sample data');
      return;
    }

    final List<Map<String, dynamic>> sampleBooks = [
      {
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'isbn': '978-0-7432-7356-5',
        'description': 'A classic American novel set in the Jazz Age, exploring themes of wealth, love, and the American Dream.',
        'category': 'Fiction',
        'availableCopies': 5,
        'totalCopies': 5,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'isbn': '978-0-452-28423-4',
        'description': 'A dystopian novel about totalitarianism and surveillance in a society ruled by Big Brother.',
        'category': 'Fiction',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'isbn': '978-0-06-112008-4',
        'description': 'A powerful story about racial injustice and childhood innocence in the American South.',
        'category': 'Fiction',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'A Brief History of Time',
        'author': 'Stephen Hawking',
        'isbn': '978-0-553-38016-3',
        'description': 'An exploration of cosmology, black holes, and the nature of time by renowned physicist Stephen Hawking.',
        'category': 'Science',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Sapiens: A Brief History of Humankind',
        'author': 'Yuval Noah Harari',
        'isbn': '978-0-06-231609-7',
        'description': 'A thought-provoking journey through the history of humanity, from the Stone Age to modern times.',
        'category': 'History',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'The Lean Startup',
        'author': 'Eric Ries',
        'isbn': '978-0-307-88789-4',
        'description': 'A revolutionary approach to building and managing startups based on validated learning.',
        'category': 'Business',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Clean Code',
        'author': 'Robert C. Martin',
        'isbn': '978-0-13-235088-4',
        'description': 'A handbook of agile software craftsmanship with best practices for writing clean, maintainable code.',
        'category': 'Technology',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'The Alchemist',
        'author': 'Paulo Coelho',
        'isbn': '978-0-06-231500-7',
        'description': 'A magical fable about following your dreams and listening to your heart.',
        'category': 'Fiction',
        'availableCopies': 6,
        'totalCopies': 6,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Educated',
        'author': 'Tara Westover',
        'isbn': '978-0-399-59050-4',
        'description': 'A memoir about a young woman who grows up in a survivalist family and eventually earns a PhD from Cambridge.',
        'category': 'Biography',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'isbn': '978-0-7352-1129-2',
        'description': 'An easy and proven way to build good habits and break bad ones through small changes.',
        'category': 'Self-Help',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Add all sample books to Firestore
    for (var book in sampleBooks) {
      await firestore.collection('books').add(book);
    }

    print('Successfully added ${sampleBooks.length} sample books!');
  }
}
