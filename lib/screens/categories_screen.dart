import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import 'book_details_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    
    // Get unique categories from all books (flatten all category lists)
    final Set<String> categorySet = {};
    for (var book in bookProvider.books) {
      categorySet.addAll(book.categories);
    }
    final categories = categorySet.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Categories Available',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                // Get books that have this category in their categories list
                final booksInCategory = bookProvider.books
                    .where((book) => book.categories.contains(category))
                    .toList();

                return _CategoryCard(
                  category: category,
                  bookCount: booksInCategory.length,
                  books: booksInCategory,
                );
              },
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int bookCount;
  final List<Book> books;

  const _CategoryCard({
    required this.category,
    required this.bookCount,
    required this.books,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fiction':
        return const Color(0xFF007AFF); // iOS Blue
      case 'history':
        return const Color(0xFFFF9500); // iOS Orange
      case 'science':
        return const Color(0xFF34C759); // iOS Green
      case 'technology':
        return const Color(0xFF5856D6); // iOS Purple
      case 'philosophy':
        return const Color(0xFF5AC8FA); // iOS Teal
      case 'mystery':
      case 'thriller':
        return const Color(0xFFFF3B30); // iOS Red
      case 'fantasy':
        return const Color(0xFFAF52DE); // iOS Pink
      case 'romance':
        return const Color(0xFFFF2D55); // iOS Pink/Red
      case 'horror':
        return const Color(0xFF8E8E93); // iOS Gray
      case 'biography':
      case 'autobiography':
        return const Color(0xFFFFCC00); // iOS Yellow
      case 'poetry':
        return const Color(0xFFFF6482); // Light Pink
      case 'drama':
        return const Color(0xFF30B0C7); // Cyan
      default:
        return const Color(0xFF007AFF); // iOS Blue
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fiction':
        return Icons.auto_stories_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'technology':
        return Icons.devices_rounded;
      case 'philosophy':
        return Icons.psychology_alt_rounded;
      case 'mystery':
        return Icons.search_rounded;
      case 'thriller':
        return Icons.bolt_rounded;
      case 'fantasy':
        return Icons.castle_rounded;
      case 'romance':
        return Icons.favorite_rounded;
      case 'horror':
        return Icons.nights_stay_rounded;
      case 'biography':
      case 'autobiography':
        return Icons.person_rounded;
      case 'poetry':
        return Icons.format_quote_rounded;
      case 'drama':
        return Icons.theater_comedy_rounded;
      case 'general':
        return Icons.menu_book_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _CategoryBooksScreen(
                category: category,
                books: books,
                color: color,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$bookCount ${bookCount == 1 ? 'book' : 'books'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBooksScreen extends StatelessWidget {
  final String category;
  final List<Book> books;
  final Color color;

  const _CategoryBooksScreen({
    required this.category,
    required this.books,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(book: book),
                  ),
                );
              },
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: book.coverUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.menu_book, color: color);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: color,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.menu_book, color: color),
              ),
              title: Text(
                book.title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        book.availableCopies > 0
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 14,
                        color: book.availableCopies > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.availableCopies} available',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: book.availableCopies > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
            ),
            ),
          );
        },
      ),
    );
  }
}
