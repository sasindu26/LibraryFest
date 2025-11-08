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
      appBar: AppBar(
        title: Text(
          'Borrowing History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowedBooks')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('borrowedDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Borrowing History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your borrowed books will appear here',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final borrowedDate = (data['borrowedDate'] as Timestamp?)?.toDate();
              final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
              final returnedDate = (data['returnedDate'] as Timestamp?)?.toDate();
              final isReturned = data['isReturned'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('books')
                      .doc(data['bookId'])
                      .get(),
                  builder: (context, bookSnapshot) {
                    if (!bookSnapshot.hasData) {
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    final bookData = bookSnapshot.data!.data() as Map<String, dynamic>?;
                    final bookTitle = bookData?['title'] ?? 'Unknown Book';
                    final bookAuthor = bookData?['author'] ?? 'Unknown Author';

                    return ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isReturned ? Colors.green[100] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isReturned ? Icons.check_circle : Icons.book,
                          color: isReturned ? Colors.green : Colors.blue,
                        ),
                      ),
                      title: Text(
                        bookTitle,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            bookAuthor,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Borrowed: ${borrowedDate != null ? DateFormat('MMM dd, yyyy').format(borrowedDate) : 'N/A'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (isReturned && returnedDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.event_available, size: 14, color: Colors.green[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Returned: ${DateFormat('MMM dd, yyyy').format(returnedDate)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!isReturned && dueDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 14,
                                    color: dueDate.isBefore(DateTime.now()) ? Colors.red : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: dueDate.isBefore(DateTime.now()) ? Colors.red : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isReturned ? Colors.green[50] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isReturned ? Colors.green : Colors.blue,
                          ),
                        ),
                        child: Text(
                          isReturned ? 'Returned' : 'Borrowed',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isReturned ? Colors.green[700] : Colors.blue[700],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
