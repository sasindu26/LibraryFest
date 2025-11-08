import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'book_reader_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isFavorite = false;
  bool _isCheckingFavorite = true;
  bool _isStoryExpanded = false;
  bool _isAlreadyBorrowed = false;
  bool _isCheckingBorrowed = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _checkIfAlreadyBorrowed();
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

  Future<void> _checkIfAlreadyBorrowed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isCheckingBorrowed = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('borrowedBooks')
          .where('userId', isEqualTo: user.uid)
          .where('bookId', isEqualTo: widget.book.id)
          .where('isReturned', isEqualTo: false)
          .get();

      if (mounted) {
        setState(() {
          _isAlreadyBorrowed = snapshot.docs.isNotEmpty;
          _isCheckingBorrowed = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingBorrowed = false;
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
              content: Text('Removed from favorites', style: GoogleFonts.inter()),
              backgroundColor: const Color(0xFFFF9500),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
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
              content: Text('Added to favorites', style: GoogleFonts.inter()),
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
            content: Text('Error: $e', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _borrowBook() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to borrow books', style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (widget.book.availableCopies <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No copies available', style: GoogleFonts.inter()),
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
        title: Text('Borrow Book', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Text('Do you want to borrow "${widget.book.title}"?', style: GoogleFonts.inter(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Borrow', style: GoogleFonts.inter(color: const Color(0xFF007AFF), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await bookProvider.borrowBook(widget.book.id, user.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Borrow request submitted! Waiting for admin approval.' : 'Failed to submit request',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: success ? const Color(0xFFFF9500) : const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        // Refresh the borrowed status
        if (success) {
          _checkIfAlreadyBorrowed();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF007AFF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _isCheckingFavorite
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF007AFF),
                      const Color(0xFF5856D6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: widget.book.coverUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.book.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildGradientCover();
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildGradientCover(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.book.title,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Author
                  Text(
                    'by ${widget.book.author}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey[600],
                      letterSpacing: -0.24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating and Year Row
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFF9500),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.book.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFFFF9500),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' / 5.0',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Published Year
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Color(0xFF007AFF),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.book.publishedYear.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF007AFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category & Availability Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5856D6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.book.category,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF5856D6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.inventory_2_rounded,
                        size: 18,
                        color: widget.book.availableCopies > 0
                            ? const Color(0xFF34C759)
                            : const Color(0xFFFF3B30),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.book.availableCopies}/${widget.book.totalCopies} available',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: widget.book.availableCopies > 0
                              ? const Color(0xFF34C759)
                              : const Color(0xFFFF3B30),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Short Description
                  Text(
                    'About this book',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.book.description.length > 200 && !_isStoryExpanded
                        ? '${widget.book.description.substring(0, 200)}...'
                        : widget.book.description,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[800],
                      letterSpacing: -0.24,
                    ),
                  ),
                  if (widget.book.description.length > 200)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isStoryExpanded = !_isStoryExpanded;
                        });
                      },
                      child: Text(
                        _isStoryExpanded ? 'Show Less' : 'Read Full Story',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Book Info
                  Container(
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
                        Text(
                          'Book Details',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('ISBN', widget.book.isbn),
                        const Divider(height: 24),
                        _buildInfoRow('Author', widget.book.author),
                        const Divider(height: 24),
                        _buildInfoRow('Category', widget.book.category),
                        const Divider(height: 24),
                        _buildInfoRow('Rating', '${widget.book.rating} / 5.0'),
                        const Divider(height: 24),
                        _buildInfoRow('Published', widget.book.publishedYear.toString()),
                        const Divider(height: 24),
                        _buildInfoRow('Total Copies', '${widget.book.totalCopies}'),
                        const Divider(height: 24),
                        _buildInfoRow('Available', '${widget.book.availableCopies}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Read Book Button (always visible if borrowed)
              if (_isAlreadyBorrowed)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookReaderScreen(book: widget.book),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5856D6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Read Book',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Borrow/Status Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAlreadyBorrowed 
                      ? null 
                      : (widget.book.availableCopies > 0 ? _borrowBook : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAlreadyBorrowed
                        ? const Color(0xFF34C759)
                        : const Color(0xFF007AFF),
                    disabledBackgroundColor: _isAlreadyBorrowed
                        ? const Color(0xFF34C759)
                        : const Color(0xFFD1D1D6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAlreadyBorrowed
                            ? Icons.check_circle_rounded
                            : (widget.book.availableCopies > 0
                                ? Icons.bookmark_add_rounded
                                : Icons.block_rounded),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isAlreadyBorrowed
                            ? 'Already Borrowed'
                            : (widget.book.availableCopies > 0 ? 'Borrow Book' : 'Not Available'),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
      ),
    );
  }

  Widget _buildGradientCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF007AFF),
            const Color(0xFF5856D6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.grey[600],
            letterSpacing: -0.24,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }
}
