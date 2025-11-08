import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import 'book_details_screen.dart';

class CurrentBorrowedScreen extends StatelessWidget {
  const CurrentBorrowedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          // iOS-style AppBar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF2F2F7),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF007AFF)),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Borrowed Books',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.37,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          // Borrowed Books List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('borrowedBooks')
                .where('userId', isEqualTo: user?.uid)
                .where('isReturned', isEqualTo: false)
                .where('status', isEqualTo: 'approved') // ONLY approved books
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Oops! Something went wrong',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We couldn\'t load your borrowed books.\nPlease try again later.',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: Text(
                              'Go Back',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF007AFF),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.library_books_rounded,
                            size: 80,
                            color: const Color(0xFFFF9500).withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Borrowed Books',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'You haven\'t borrowed any books yet.\nVisit the catalog to find your next great read!',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      // Handle different date formats (Timestamp or String)
                      DateTime? borrowedDate;
                      if (data['borrowedDate'] is Timestamp) {
                        borrowedDate = (data['borrowedDate'] as Timestamp).toDate();
                      } else if (data['borrowedDate'] is String) {
                        borrowedDate = DateTime.tryParse(data['borrowedDate'] as String);
                      }
                      
                      DateTime? dueDate;
                      if (data['dueDate'] is Timestamp) {
                        dueDate = (data['dueDate'] as Timestamp).toDate();
                      } else if (data['dueDate'] is String) {
                        dueDate = DateTime.tryParse(data['dueDate'] as String);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BorrowedBookCard(
                          data: data,
                          borrowedDate: borrowedDate,
                          dueDate: dueDate,
                        ),
                      );
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BorrowedBookCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateTime? borrowedDate;
  final DateTime? dueDate;

  const _BorrowedBookCard({
    required this.data,
    required this.borrowedDate,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = dueDate != null && dueDate!.isBefore(DateTime.now());
    final daysUntilDue = dueDate != null ? dueDate!.difference(DateTime.now()).inDays : 0;
    final status = data['status'] ?? 'approved'; // Get actual status
    final isPending = status == 'pending';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('books')
          .doc(data['bookId'])
          .get(),
      builder: (context, bookSnapshot) {
        final bookData = bookSnapshot.data?.data() as Map<String, dynamic>?;
        final bookTitle = bookData?['title'] ?? data['bookTitle'] ?? 'Unknown Book';
        final bookAuthor = bookData?['author'] ?? data['bookAuthor'] ?? 'Unknown Author';
        final bookCategory = bookData?['category'] ?? 'General';
        final coverUrl = bookData?['coverUrl'];

        return GestureDetector(
          onTap: () {
            // Navigate to book details if book data is available
            if (bookSnapshot.hasData && bookSnapshot.data!.exists) {
              final book = Book.fromMap(
                bookSnapshot.data!.id,
                bookSnapshot.data!.data() as Map<String, dynamic>,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailsScreen(book: book),
                ),
              );
            }
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
            border: isOverdue
                ? Border.all(color: const Color(0xFFFF3B30), width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF007AFF).withOpacity(0.8),
                        const Color(0xFF5AC8FA).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: coverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookTitle,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          letterSpacing: -0.41,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bookAuthor,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey[600],
                          letterSpacing: -0.24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5856D6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bookCategory,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF5856D6),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.08,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Dates
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Borrowed: ${borrowedDate != null ? DateFormat('MMM dd').format(borrowedDate!) : 'N/A'}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[700],
                              letterSpacing: -0.08,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isOverdue ? Icons.warning_rounded : Icons.event_rounded,
                            size: 14,
                            color: isOverdue
                                ? const Color(0xFFFF3B30)
                                : const Color(0xFFFF9500),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOverdue
                                ? 'Overdue by ${-daysUntilDue} days'
                                : 'Due in $daysUntilDue days',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isOverdue
                                  ? const Color(0xFFFF3B30)
                                  : const Color(0xFFFF9500),
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.08,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending
                        ? const Color(0xFFFF9500).withOpacity(0.1)
                        : isOverdue
                            ? const Color(0xFFFF3B30).withOpacity(0.1)
                            : const Color(0xFF34C759).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPending ? 'Pending' : (isOverdue ? 'Overdue' : 'Borrowed'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPending
                          ? const Color(0xFFFF9500)
                          : isOverdue
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF34C759),
                      letterSpacing: -0.08,
                    ),
                  ),
                ),
              ],
            ),
          ), // Close Padding
        ), // Close Container (child of GestureDetector)
        ); // Close GestureDetector
      },
    );
  }
}
