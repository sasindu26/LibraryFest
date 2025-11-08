import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import 'book_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          return CustomScrollView(
            slivers: [
              // iOS-style AppBar with Logo
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFFF2F2F7),
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/Library.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    children: [
                      const SizedBox(width: 60), // Space for logo
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
                  titlePadding: const EdgeInsets.only(left: 0, bottom: 16),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // iOS-style Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Container(
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
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            letterSpacing: -0.41,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search books...',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 17,
                              letterSpacing: -0.41,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey[400],
                              size: 22,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.cancel_rounded,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                      bookProvider.clearSearch();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            bookProvider.searchBooks(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Book List
              bookProvider.isLoading
                  ? const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    )
                  : bookProvider.books.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.library_books_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No books found',
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    color: Colors.grey[600],
                                    letterSpacing: -0.41,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final book = bookProvider.books[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _IOSBookCard(book: book),
                                );
                              },
                              childCount: bookProvider.books.length,
                            ),
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }
}

class _IOSBookCard extends StatefulWidget {
  final Book book;

  const _IOSBookCard({required this.book});

  @override
  State<_IOSBookCard> createState() => _IOSBookCardState();
}

class _IOSBookCardState extends State<_IOSBookCard> {
  bool _isFavorite = false;
  bool _isCheckingFavorite = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isCheckingFavorite = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .where('bookId', isEqualTo: widget.book.id)
          .get();

      if (mounted) {
        setState(() {
          _isFavorite = snapshot.docs.isNotEmpty;
          _isCheckingFavorite = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to add favorites',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      if (_isFavorite) {
        // Remove from favorites
        final snapshot = await FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user.uid)
            .where('bookId', isEqualTo: widget.book.id)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        if (mounted) {
          setState(() {
            _isFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Removed from favorites',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: const Color(0xFFFF9500),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        // Add to favorites
        await FirebaseFirestore.instance.collection('favorites').add({
          'userId': user.uid,
          'bookId': widget.book.id,
          'addedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added to favorites',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: const Color(0xFF34C759),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _borrowBook(BuildContext context, Book book) async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to borrow books',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (book.availableCopies <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No copies available',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFFFF9500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Borrow Book',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Do you want to borrow "${book.title}"?',
          style: GoogleFonts.inter(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Borrow',
              style: GoogleFonts.inter(
                color: const Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await bookProvider.borrowBook(book.id, user.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Book borrowed successfully!'
                  : 'Failed to borrow book. Please try again.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: success ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: widget.book),
          ),
        );
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Book Cover
                Container(
                  width: 80,
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.book.coverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.book.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF007AFF).withOpacity(0.8),
                                      const Color(0xFF5856D6).withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    size: 40,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF007AFF).withOpacity(0.8),
                                      const Color(0xFF5856D6).withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 40,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Book Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.book.title,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.41,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Favorite Button
                          _isCheckingFavorite
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFF3B30),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: const Color(0xFFFF3B30),
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: _toggleFavorite,
                                ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${widget.book.author}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey[600],
                          letterSpacing: -0.24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.book.categories.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5856D6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF5856D6),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.08,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 16,
                            color: widget.book.availableCopies > 0
                                ? const Color(0xFF34C759)
                                : const Color(0xFFFF3B30),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.book.availableCopies}/${widget.book.totalCopies} available',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: widget.book.availableCopies > 0
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFFFF3B30),
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.08,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.book.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.book.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                  letterSpacing: -0.24,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: widget.book.availableCopies > 0
                    ? () => _borrowBook(context, widget.book)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  disabledBackgroundColor: const Color(0xFFD1D1D6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.book.availableCopies > 0
                          ? Icons.bookmark_add_rounded
                          : Icons.block_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.book.availableCopies > 0 ? 'Borrow Book' : 'Not Available',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ), // Close Container (child of GestureDetector)
    ); // Close GestureDetector (return statement)
  } // Close build method
} // Close _IOSBookCardState
