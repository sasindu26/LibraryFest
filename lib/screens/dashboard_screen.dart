import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'catalog_screen.dart';
import 'borrowing_history_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'current_borrowed_screen.dart';
import 'book_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS background
      body: CustomScrollView(
        slivers: [
          // iOS-style large title with logo and LibraryFest branding
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF2F2F7),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/Library.jpg',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LibraryFest',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF007AFF),
                      letterSpacing: 0.37,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Welcome Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF007AFF), // iOS Blue
                          Color(0xFF5856D6), // iOS Purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007AFF).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: user?.photoURL != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    user!.photoURL!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.08,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email?.toLowerCase().contains('admin') ?? false
                                    ? 'Admin'
                                    : user?.displayName ?? 'Reader',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.24,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.library_books_rounded,
                          size: 32,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CatalogScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.grey[400],
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search for books...',
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 17,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Stats Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Quick Stats',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _IOSStatCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Total Books',
                          value: '${bookProvider.books.length}',
                          color: const Color(0xFF007AFF), // iOS Blue
                          gradientColors: const [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CatalogScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('borrowedBooks')
                              .where('userId', isEqualTo: user?.uid)
                              .where('isReturned', isEqualTo: false)
                              .where('status', isEqualTo: 'approved')
                              .snapshots(),
                          builder: (context, snapshot) {
                            // Show loading state immediately with 0
                            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                              return _IOSStatCard(
                                icon: Icons.bookmark_rounded,
                                title: 'Borrowed',
                                value: '0',
                                color: const Color(0xFFFF9500),
                                gradientColors: const [Color(0xFFFF9500), Color(0xFFFF6482)],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CurrentBorrowedScreen(),
                                    ),
                                  );
                                },
                              );
                            }
                            // Count only approved books (already filtered in query)
                            final count = snapshot.data?.docs.length ?? 0;
                            return _IOSStatCard(
                              icon: Icons.bookmark_rounded,
                              title: 'Borrowed',
                              value: '$count',
                              color: const Color(0xFFFF9500), // iOS Orange
                              gradientColors: const [Color(0xFFFF9500), Color(0xFFFF6482)],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CurrentBorrowedScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('borrowedBooks')
                              .where('userId', isEqualTo: user?.uid)
                              .where('isReturned', isEqualTo: true)
                              .where('status', isEqualTo: 'approved') // Only count approved books that were returned
                              .snapshots(),
                          builder: (context, snapshot) {
                            // Show loading state immediately with 0
                            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                              return _IOSStatCard(
                                icon: Icons.check_circle_rounded,
                                title: 'Returned',
                                value: '0',
                                color: const Color(0xFF34C759),
                                gradientColors: const [Color(0xFF34C759), Color(0xFF30D158)],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BorrowingHistoryScreen(),
                                    ),
                                  );
                                },
                              );
                            }
                            final count = snapshot.data?.docs.length ?? 0;
                            return _IOSStatCard(
                              icon: Icons.check_circle_rounded,
                              title: 'Returned',
                              value: '$count',
                              color: const Color(0xFF34C759), // iOS Green
                              gradientColors: const [Color(0xFF34C759), Color(0xFF30D158)],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BorrowingHistoryScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _IOSStatCard(
                          icon: Icons.category_rounded,
                          title: 'Categories',
                          value: '${bookProvider.books.expand((b) => b.categories).toSet().length}',
                          color: const Color(0xFF5856D6), // iOS Purple
                          gradientColors: const [Color(0xFF5856D6), Color(0xFFAF52DE)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Quick Actions',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _IOSActionCard(
                        icon: Icons.bookmark_rounded,
                        title: 'Borrowed Books',
                        color: const Color(0xFFFF9500),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CurrentBorrowedScreen(),
                            ),
                          );
                        },
                      ),
                      _IOSActionCard(
                        icon: Icons.category_rounded,
                        title: 'Categories',
                        color: const Color(0xFF5856D6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesScreen(),
                            ),
                          );
                        },
                      ),
                      _IOSActionCard(
                        icon: Icons.history_rounded,
                        title: 'History',
                        color: const Color(0xFF007AFF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BorrowingHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      _IOSActionCard(
                        icon: Icons.favorite_rounded,
                        title: 'Favorites',
                        color: const Color(0xFFFF3B30),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Recently Added Books
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Recently Added',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: bookProvider.books.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_books_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No books available',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: bookProvider.books.length > 5
                              ? 5
                              : bookProvider.books.length,
                          itemBuilder: (context, index) {
                            final book = bookProvider.books[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailsScreen(book: book),
                                  ),
                                );
                              },
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF007AFF).withOpacity(0.8),
                                          const Color(0xFF5856D6).withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    child: book.coverUrl != null
                                        ? ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                            child: Image.network(
                                              book.coverUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    Icons.menu_book_rounded,
                                                    size: 48,
                                                    color: Colors.white.withOpacity(0.9),
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.menu_book_rounded,
                                              size: 48,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.24,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          book.author,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            letterSpacing: -0.08,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ), // Close Container (child of GestureDetector)
                            ); // Close GestureDetector
                          },
                        ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// iOS-style Stat Card
class _IOSStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _IOSStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 0.36,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
              letterSpacing: -0.08,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }
    return card;
  }
}

// iOS-style Action Card
class _IOSActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _IOSActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.24,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
