import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BorrowingHistoryScreen extends StatelessWidget {
  const BorrowingHistoryScreen({super.key});

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
                'History',
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
          // History List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('borrowedBooks')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Color(0xFFFF3B30),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
                        Icon(
                          Icons.history_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Borrowing History',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your borrowed books will appear here',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey[500],
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
                      
                      DateTime? returnedDate;
                      if (data['returnedDate'] is Timestamp) {
                        returnedDate = (data['returnedDate'] as Timestamp).toDate();
                      } else if (data['returnedDate'] is String) {
                        returnedDate = DateTime.tryParse(data['returnedDate'] as String);
                      }
                      
                      final isReturned = data['isReturned'] ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IOSHistoryCard(
                          data: data,
                          borrowedDate: borrowedDate,
                          dueDate: dueDate,
                          returnedDate: returnedDate,
                          isReturned: isReturned,
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

class _IOSHistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateTime? borrowedDate;
  final DateTime? dueDate;
  final DateTime? returnedDate;
  final bool isReturned;

  const _IOSHistoryCard({
    required this.data,
    required this.borrowedDate,
    required this.dueDate,
    required this.returnedDate,
    required this.isReturned,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('books')
          .doc(data['bookId'])
          .get(),
      builder: (context, bookSnapshot) {
        final bookData = bookSnapshot.data?.data() as Map<String, dynamic>?;
        final bookTitle = bookData?['title'] ?? 'Unknown Book';
        final bookAuthor = bookData?['author'] ?? 'Unknown Author';
        final bookCategory = bookData?['category'] ?? 'General';

        return Container(
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
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Icon
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isReturned
                          ? [const Color(0xFF34C759), const Color(0xFF30D158)]
                          : [const Color(0xFF007AFF), const Color(0xFF5AC8FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isReturned 
                            ? const Color(0xFF34C759) 
                            : const Color(0xFF007AFF)).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isReturned ? Icons.check_circle_rounded : Icons.bookmark_rounded,
                    color: Colors.white,
                    size: 32,
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
                      _DateRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Borrowed',
                        date: borrowedDate,
                        color: Colors.grey[700]!,
                      ),
                      if (isReturned && returnedDate != null) ...[
                        const SizedBox(height: 6),
                        _DateRow(
                          icon: Icons.event_available_rounded,
                          label: 'Returned',
                          date: returnedDate,
                          color: const Color(0xFF34C759),
                        ),
                      ],
                      if (!isReturned && dueDate != null) ...[
                        const SizedBox(height: 6),
                        _DateRow(
                          icon: Icons.event_busy_rounded,
                          label: 'Due',
                          date: dueDate,
                          color: dueDate!.isBefore(DateTime.now())
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFFFF9500),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isReturned
                        ? const Color(0xFF34C759).withOpacity(0.1)
                        : const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isReturned ? 'Returned' : 'Borrowed',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isReturned 
                          ? const Color(0xFF34C759) 
                          : const Color(0xFF007AFF),
                      letterSpacing: -0.08,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;
  final Color color;

  const _DateRow({
    required this.icon,
    required this.label,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ${date != null ? DateFormat('MMM dd, yyyy').format(date!) : 'N/A'}',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: color,
            letterSpacing: -0.08,
          ),
        ),
      ],
    );
  }
}
