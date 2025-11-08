import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';

class BorrowedScreen extends StatefulWidget {
  const BorrowedScreen({super.key});

  @override
  State<BorrowedScreen> createState() => _BorrowedScreenState();
}

class _BorrowedScreenState extends State<BorrowedScreen> {
  int _refreshKey = 0;

  Future<void> _returnBook(BuildContext context, String borrowedBookId, String bookId) async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Book'),
        content: const Text('Do you want to return this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await bookProvider.returnBook(borrowedBookId, bookId);
      if (context.mounted) {
        if (success) {
          setState(() {
            _refreshKey++;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Book returned successfully!'
                  : 'Failed to return book. Please try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login to view borrowed books'));
    }

    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    return StreamBuilder<List<BorrowedBook>>(
      // Use the new method that gets ALL books (both pending and approved)
      stream: bookProvider.getAllBorrowedBooksStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final allBooks = snapshot.data ?? [];
        // Separate into approved and pending
        final approvedBooks = allBooks.where((b) => b.status == 'approved').toList();
        final pendingBooks = allBooks.where((b) => b.status == 'pending').toList();

        if (allBooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No borrowed books',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse the catalog to borrow books',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // StreamBuilder handles real-time updates, but refresh can still work
            setState(() {
              _refreshKey++;
            });
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Pending Requests Section
              if (pendingBooks.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Approval (${pendingBooks.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pendingBooks.map((borrowedBook) => _buildBookCard(
                  context,
                  borrowedBook,
                  isPending: true,
                )),
                const SizedBox(height: 24),
              ],
              
              // Borrowed Books Section
              if (approvedBooks.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.book, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Borrowed Books (${approvedBooks.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...approvedBooks.map((borrowedBook) {
                  final isOverdue = DateTime.now().isAfter(borrowedBook.dueDate);
                  return _buildBookCard(
                    context,
                    borrowedBook,
                    isOverdue: isOverdue,
                  );
                }),
              ],
              
              if (approvedBooks.isEmpty && pendingBooks.isEmpty)
                Center(
                  child: Text(
                    'No books to display',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    BorrowedBook borrowedBook, {
    bool isPending = false,
    bool isOverdue = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? const BorderSide(color: Colors.red, width: 2)
            : isPending
                ? const BorderSide(color: Colors.orange, width: 2)
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrowedBook.bookTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${borrowedBook.bookAuthor}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PENDING APPROVAL',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Borrowed: ${_formatDate(borrowedBook.borrowedDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Due: ${_formatDate(borrowedBook.dueDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                    fontWeight:
                        isOverdue ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isPending)
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Waiting for Approval',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _returnBook(
                    context,
                    borrowedBook.id,
                    borrowedBook.bookId,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Return Book',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}


