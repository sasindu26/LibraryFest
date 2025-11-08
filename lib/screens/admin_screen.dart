import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../utils/sample_books.dart';
import 'borrowing_history_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Manage your library',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics
          Text(
            'Library Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.book,
                  title: 'Total Books',
                  value: '${bookProvider.books.length}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('borrowedBooks')
                      .where('isReturned', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _StatCard(
                      icon: Icons.people,
                      title: 'Active Borrows',
                      value: '$count',
                      color: Colors.orange,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  title: 'Available',
                  value: '${bookProvider.books.where((b) => b.available).length}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.category,
                  title: 'Categories',
                  value: '${bookProvider.books.expand((b) => b.categories).toSet().length}',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _ActionCard(
                icon: Icons.add_box,
                title: 'Add New Book',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddBookScreen()),
                  );
                },
              ),
              _ActionCard(
                icon: Icons.library_books,
                title: 'Manage Books',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageBooksScreen()),
                  );
                },
              ),
              _ActionCard(
                icon: Icons.pending_actions,
                title: 'Borrow Requests',
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BorrowRequestsScreen()),
                  );
                },
              ),
              _ActionCard(
                icon: Icons.delete_outline,
                title: 'Delete Book',
                color: Colors.deepOrange,
                onTap: () {
                  _showDeleteBookDialog(context);
                },
              ),
              _ActionCard(
                icon: Icons.search_rounded,
                title: 'Track Borrowers',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackBorrowersScreen()),
                  );
                },
              ),
              _ActionCard(
                icon: Icons.history,
                title: 'Borrowing History',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BorrowingHistoryScreen()),
                  );
                },
              ),
              _ActionCard(
                icon: Icons.delete_sweep,
                title: 'Clear All Books',
                color: Colors.red,
                onTap: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Clear All Books?',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'This will delete ALL books from the database. This action cannot be undone!',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Delete All'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true && context.mounted) {
                    try {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Deleting all books...',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      // Delete all books
                      final booksSnapshot = await FirebaseFirestore.instance
                          .collection('books')
                          .get();
                      
                      for (var doc in booksSnapshot.docs) {
                        await doc.reference.delete();
                      }
                      
                      // Refresh the BookProvider
                      if (context.mounted) {
                        final bookProvider = Provider.of<BookProvider>(context, listen: false);
                        await bookProvider.fetchBooks();
                        
                        Navigator.of(context).pop(); // Close loading dialog
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All books deleted successfully!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting books: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              _ActionCard(
                icon: Icons.data_object,
                title: 'Add Sample Data',
                color: Colors.purple,
                onTap: () async {
                  final shouldAdd = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Add Sample Books?',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'This will add 21 sample books with categories and cover images.\n\nCategories: Fiction, History, Science, Technology, Philosophy, Mystery, Fantasy',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Add Books'),
                        ),
                      ],
                    ),
                  );

                  if (shouldAdd == true && context.mounted) {
                    try {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Adding sample books...',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      await SampleBooksData.addSampleBooks();
                      
                      // Refresh the BookProvider
                      if (context.mounted) {
                        final bookProvider = Provider.of<BookProvider>(context, listen: false);
                        await bookProvider.fetchBooks();
                        
                        Navigator.of(context).pop(); // Close loading dialog
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sample books added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error adding sample books: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );
  }

  void _showManageBooksDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageBooksScreen()),
    );
  }

  void _showBorrowedBooksDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BorrowedBooksManagementScreen()),
    );
  }

  void _showDeleteBookDialog(BuildContext context) async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Delete Book',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search book by title...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setDialogState(() {
                            searchResults = [];
                          });
                          return;
                        }
                        
                        final results = bookProvider.books
                            .where((book) =>
                                book.title.toLowerCase().contains(value.toLowerCase()))
                            .take(5)
                            .map((book) => {
                                  'id': book.id,
                                  'title': book.title,
                                  'author': book.author,
                                })
                            .toList();
                        
                        setDialogState(() {
                          searchResults = results;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (searchResults.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final book = searchResults[index];
                            return ListTile(
                              title: Text(
                                book['title']!,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                'by ${book['author']}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Confirm Delete',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete "${book['title']}"?',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('books')
                                          .doc(book['id'])
                                          .delete();

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Book "${book['title']}" deleted successfully!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error deleting book: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      )
                    else if (searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No books found',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Add Book Screen
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_titleController.text.trim()}.jpg';
      final ref = FirebaseStorage.instance.ref().child('book_covers/$fileName');
      
      await ref.putFile(_imageFile!);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _addBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload image if selected
        String? coverUrl;
        if (_imageFile != null) {
          coverUrl = await _uploadImage();
        }

        await FirebaseFirestore.instance.collection('books').add({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'isbn': _isbnController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categories': _categoryController.text.trim().split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList(),
          'availableCopies': 3, // Default number of copies
          'totalCopies': 3,
          'coverUrl': coverUrl, // Add the cover URL
          'available': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Refresh the BookProvider to update the dashboard statistics
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        await bookProvider.fetchBooks();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Book',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book Cover Image Picker
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.blue[300],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Cover Image',
                                    style: GoogleFonts.inter(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to select',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (_imageFile != null) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          'Remove Image',
                          style: GoogleFonts.inter(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title *',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter book title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _isbnController,
                decoration: InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Categories *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'e.g., Fiction, Science, History (comma-separated)',
                  helperText: 'Separate multiple categories with commas',
                  helperMaxLines: 2,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _addBook,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _isLoading ? 'Adding...' : 'Add Book',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
}

// Manage Books Screen
class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Books',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: bookProvider.books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No books available',
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
              itemCount: bookProvider.books.length,
              itemBuilder: (context, index) {
                final book = bookProvider.books[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: book.available ? Colors.green : Colors.orange,
                      child: Icon(
                        book.available ? Icons.check : Icons.access_time,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      book.title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${book.author} • ${book.categories.join(', ')}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text('Edit', style: GoogleFonts.poppins()),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBookScreen(book: book),
                                ),
                              );
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('Delete', style: GoogleFonts.poppins()),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              _showDeleteConfirmation(context, book.id);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete this book? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Book deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting book: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}

// Edit Book Screen
class EditBookScreen extends StatefulWidget {
  final dynamic book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _isbnController = TextEditingController(text: widget.book.isbn);
    _descriptionController = TextEditingController(text: widget.book.description);
    _categoryController = TextEditingController(text: widget.book.categories.join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('books').doc(widget.book.id).update({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'isbn': _isbnController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categories': _categoryController.text.trim().split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Book',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.edit_note, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title *',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter book title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter author name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _isbnController,
                decoration: InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Categories *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g., Fiction, Science, History (comma-separated)',
                  helperText: 'Separate multiple categories with commas',
                  helperMaxLines: 2,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter at least one category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateBook,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Updating...' : 'Update Book',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Borrowed Books Management Screen
class BorrowedBooksManagementScreen extends StatelessWidget {
  const BorrowedBooksManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Borrowed Books',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowedBooks')
            .orderBy('borrowedDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No borrowed books',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isReturned = data['isReturned'] ?? false;
              final borrowDate = (data['borrowedDate'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReturned ? Colors.green : Colors.orange,
                    child: Icon(
                      isReturned ? Icons.check_circle : Icons.access_time,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['bookTitle'] ?? 'Unknown Book',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'User: ${data['userName'] ?? 'Unknown'}\nBorrowed: ${borrowDate != null ? "${borrowDate.day}/${borrowDate.month}/${borrowDate.year}" : "N/A"}',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isReturned ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isReturned ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Text(
                      isReturned ? 'Returned' : 'Borrowed',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isReturned ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// User Selection Dialog for Sample Borrowed Books
class _UserSelectionDialog extends StatelessWidget {
  const _UserSelectionDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select User',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading users');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No users found in database.'),
                  const SizedBox(height: 16),
                  Text(
                    'Use current user instead?',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                      if (currentUserId != null) {
                        Navigator.of(context).pop(currentUserId);
                      }
                    },
                    child: const Text('Use My Account'),
                  ),
                ],
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final email = data['email'] ?? 'No email';
                final displayName = data['displayName'] ?? email.split('@')[0];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(displayName[0].toUpperCase()),
                  ),
                  title: Text(
                    displayName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    email,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(doc.id);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// Sample Books Data
class SampleBooksData {
  static Future<void> addSampleBooks() async {
    final books = [
      // Fiction
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'isbn': '978-0061120084',
        'category': 'Fiction',
        'description': 'A gripping tale of racial injustice and childhood innocence in the American South.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780061120084-L.jpg',
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'isbn': '978-0451524935',
        'category': 'Fiction',
        'description': 'A dystopian social science fiction novel and cautionary tale.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',
      },
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'isbn': '978-0141439518',
        'category': 'Fiction',
        'description': 'A romantic novel of manners set in Georgian England.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg',
      },
      
      // History
      {
        'title': 'Sapiens: A Brief History of Humankind',
        'author': 'Yuval Noah Harari',
        'isbn': '978-0062316110',
        'category': 'History',
        'description': 'An exploration of how Homo sapiens came to dominate the world.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780062316110-L.jpg',
      },
      {
        'title': 'Guns, Germs, and Steel',
        'author': 'Jared Diamond',
        'isbn': '978-0393317558',
        'category': 'History',
        'description': 'The fates of human societies and the roots of inequality.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780393317558-L.jpg',
      },
      {
        'title': 'The Silk Roads: A New History',
        'author': 'Peter Frankopan',
        'isbn': '978-1101912379',
        'category': 'History',
        'description': 'A fresh look at world history from the perspective of the East.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781101912379-L.jpg',
      },
      {
        'title': 'A People\'s History of the United States',
        'author': 'Howard Zinn',
        'isbn': '978-0060838652',
        'category': 'History',
        'description': 'American history from the perspective of common people.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780060838652-L.jpg',
      },
      {
        'title': 'The Rise and Fall of the Third Reich',
        'author': 'William L. Shirer',
        'isbn': '978-1451651683',
        'category': 'History',
        'description': 'A comprehensive history of Nazi Germany.',
        'availableCopies': 1,
        'totalCopies': 1,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781451651683-L.jpg',
      },
      {
        'title': 'SPQR: A History of Ancient Rome',
        'author': 'Mary Beard',
        'isbn': '978-1631492228',
        'category': 'History',
        'description': 'The history of ancient Rome from its founding to 212 CE.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781631492228-L.jpg',
      },
      {
        'title': 'The History of the Ancient World',
        'author': 'Susan Wise Bauer',
        'isbn': '978-0393059748',
        'category': 'History',
        'description': 'From the earliest accounts to the fall of Rome.',
        'availableCopies': 1,
        'totalCopies': 1,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780393059748-L.jpg',
      },
      
      // Science
      {
        'title': 'A Brief History of Time',
        'author': 'Stephen Hawking',
        'isbn': '978-0553380163',
        'category': 'Science',
        'description': 'From the Big Bang to black holes, a journey through space and time.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780553380163-L.jpg',
      },
      {
        'title': 'The Selfish Gene',
        'author': 'Richard Dawkins',
        'isbn': '978-0198788607',
        'category': 'Science',
        'description': 'A gene-centered view of evolution.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780198788607-L.jpg',
      },
      {
        'title': 'Cosmos',
        'author': 'Carl Sagan',
        'isbn': '978-0345539434',
        'category': 'Science',
        'description': 'A journey through the universe and scientific discovery.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780345539434-L.jpg',
      },
      
      // Technology
      {
        'title': 'The Innovators',
        'author': 'Walter Isaacson',
        'isbn': '978-1476708706',
        'category': 'Technology',
        'description': 'How a group of hackers, geniuses, and geeks created the digital revolution.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781476708706-L.jpg',
      },
      {
        'title': 'Steve Jobs',
        'author': 'Walter Isaacson',
        'isbn': '978-1451648539',
        'category': 'Technology',
        'description': 'The exclusive biography of Apple\'s co-founder.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781451648539-L.jpg',
      },
      
      // Philosophy
      {
        'title': 'Meditations',
        'author': 'Marcus Aurelius',
        'isbn': '978-0812968255',
        'category': 'Philosophy',
        'description': 'Personal writings of the Roman Emperor on Stoic philosophy.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780812968255-L.jpg',
      },
      {
        'title': 'The Republic',
        'author': 'Plato',
        'isbn': '978-0140449143',
        'category': 'Philosophy',
        'description': 'Plato\'s influential dialogue on justice and the ideal state.',
        'availableCopies': 1,
        'totalCopies': 1,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780140449143-L.jpg',
      },
      
      // Mystery
      {
        'title': 'The Da Vinci Code',
        'author': 'Dan Brown',
        'isbn': '978-0307474278',
        'category': 'Mystery',
        'description': 'A mystery thriller involving art, secret societies, and conspiracy.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780307474278-L.jpg',
      },
      {
        'title': 'And Then There Were None',
        'author': 'Agatha Christie',
        'isbn': '978-0062073488',
        'category': 'Mystery',
        'description': 'Ten strangers trapped on an island, accused of murder.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780062073488-L.jpg',
      },
      
      // Fantasy
      {
        'title': 'The Hobbit',
        'author': 'J.R.R. Tolkien',
        'isbn': '978-0547928227',
        'category': 'Fantasy',
        'description': 'A fantasy adventure of a hobbit\'s unexpected journey.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780547928227-L.jpg',
      },
      {
        'title': 'Harry Potter and the Sorcerer\'s Stone',
        'author': 'J.K. Rowling',
        'isbn': '978-0439708180',
        'category': 'Fantasy',
        'description': 'The first book in the magical Harry Potter series.',
        'availableCopies': 5,
        'totalCopies': 5,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780439708180-L.jpg',
      },
      
      // More Engaging Fiction Stories
      {
        'title': 'The Alchemist',
        'author': 'Paulo Coelho',
        'isbn': '978-0062315007',
        'category': 'Fiction',
        'description': 'A magical story about following your dreams. Santiago, a shepherd boy, journeys from Spain to Egypt in search of treasure and discovers the true meaning of life.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780062315007-L.jpg',
      },
      {
        'title': 'The Kite Runner',
        'author': 'Khaled Hosseini',
        'isbn': '978-1594631931',
        'category': 'Fiction',
        'description': 'A powerful story of friendship, betrayal, and redemption set in Afghanistan. Follow Amir\'s journey to find forgiveness and peace.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781594631931-L.jpg',
      },
      {
        'title': 'The Book Thief',
        'author': 'Markus Zusak',
        'isbn': '978-0375842207',
        'category': 'Fiction',
        'description': 'Set during World War II, death narrates the story of Liesel, a girl who steals books and shares them. A touching tale of words, friendship, and survival.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780375842207-L.jpg',
      },
      {
        'title': 'Life of Pi',
        'author': 'Yann Martel',
        'isbn': '978-0156027328',
        'category': 'Fiction',
        'description': 'An incredible survival story of a boy stranded on a lifeboat in the Pacific Ocean with a Bengal tiger. A tale of faith, hope, and the will to live.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780156027328-L.jpg',
      },
      {
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'isbn': '978-0743273565',
        'category': 'Fiction',
        'description': 'A classic American novel about love, wealth, and the American Dream in the Jazz Age. Jay Gatsby\'s obsession with Daisy Buchanan leads to tragedy.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780743273565-L.jpg',
      },
      {
        'title': 'The Catcher in the Rye',
        'author': 'J.D. Salinger',
        'isbn': '978-0316769174',
        'category': 'Fiction',
        'description': 'Holden Caulfield\'s story of teenage rebellion and alienation. A coming-of-age novel that captures the confusion of adolescence.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780316769174-L.jpg',
      },
      
      // Adventure & Thriller Stories
      {
        'title': 'The Count of Monte Cristo',
        'author': 'Alexandre Dumas',
        'isbn': '978-0140449266',
        'category': 'Fiction',
        'description': 'An epic tale of betrayal, imprisonment, and revenge. Edmond Dantès escapes from prison and seeks vengeance against those who wronged him.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780140449266-L.jpg',
      },
      {
        'title': 'The Three Musketeers',
        'author': 'Alexandre Dumas',
        'isbn': '978-0140449815',
        'category': 'Fiction',
        'description': 'Join d\'Artagnan and the musketeers in 17th century France for swashbuckling adventures. "All for one and one for all!"',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780140449815-L.jpg',
      },
      {
        'title': 'Treasure Island',
        'author': 'Robert Louis Stevenson',
        'isbn': '978-0141321004',
        'category': 'Fiction',
        'description': 'A classic pirate adventure! Young Jim Hawkins finds a treasure map and sets sail with Long John Silver in search of buried gold.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780141321004-L.jpg',
      },
      {
        'title': 'Around the World in Eighty Days',
        'author': 'Jules Verne',
        'isbn': '978-0140449068',
        'category': 'Fiction',
        'description': 'Phileas Fogg makes a bet that he can circumnavigate the globe in just 80 days. An exciting race against time full of unexpected adventures!',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780140449068-L.jpg',
      },
      
      // More Fantasy & Adventure
      {
        'title': 'The Lord of the Rings: The Fellowship of the Ring',
        'author': 'J.R.R. Tolkien',
        'isbn': '978-0544003415',
        'category': 'Fantasy',
        'description': 'The epic journey begins as Frodo sets out to destroy the One Ring. Join the Fellowship in their quest to save Middle-earth from darkness.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780544003415-L.jpg',
      },
      {
        'title': 'The Chronicles of Narnia: The Lion, the Witch and the Wardrobe',
        'author': 'C.S. Lewis',
        'isbn': '978-0064471046',
        'category': 'Fantasy',
        'description': 'Step through the wardrobe into the magical land of Narnia. Four children join Aslan to defeat the White Witch and bring back spring.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780064471046-L.jpg',
      },
      {
        'title': 'Percy Jackson and the Lightning Thief',
        'author': 'Rick Riordan',
        'isbn': '978-0786838653',
        'category': 'Fantasy',
        'description': 'Percy discovers he\'s a demigod and must prevent a war between the Greek gods. Modern mythology meets thrilling adventure!',
        'availableCopies': 5,
        'totalCopies': 5,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780786838653-L.jpg',
      },
      
      // Mystery & Suspense
      {
        'title': 'The Girl with the Dragon Tattoo',
        'author': 'Stieg Larsson',
        'isbn': '978-0307454546',
        'category': 'Mystery',
        'description': 'A journalist and a brilliant hacker investigate a decades-old disappearance. Dark secrets and conspiracy await in this gripping thriller.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780307454546-L.jpg',
      },
      {
        'title': 'Gone Girl',
        'author': 'Gillian Flynn',
        'isbn': '978-0307588371',
        'category': 'Mystery',
        'description': 'When Amy disappears on her wedding anniversary, her husband becomes the prime suspect. But nothing is what it seems in this psychological thriller.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780307588371-L.jpg',
      },
      {
        'title': 'The Adventures of Sherlock Holmes',
        'author': 'Arthur Conan Doyle',
        'isbn': '978-0140437713',
        'category': 'Mystery',
        'description': 'Join the world\'s greatest detective and Dr. Watson as they solve perplexing cases in Victorian London. Brilliant deduction meets thrilling mysteries!',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780140437713-L.jpg',
      },
      
      // Inspiring Stories
      {
        'title': 'The Little Prince',
        'author': 'Antoine de Saint-Exupéry',
        'isbn': '978-0156012195',
        'category': 'Fiction',
        'description': 'A magical tale about a young prince who travels from planet to planet. A timeless story about love, loss, and what truly matters in life.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780156012195-L.jpg',
      },
      {
        'title': 'The Secret Garden',
        'author': 'Frances Hodgson Burnett',
        'isbn': '978-0141321066',
        'category': 'Fiction',
        'description': 'Mary discovers a hidden garden and transforms not only the garden but herself and those around her. A beautiful story of healing and friendship.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780141321066-L.jpg',
      },
      
      // Romance Stories
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'isbn': '978-0141439518',
        'category': 'Romance',
        'description': 'Elizabeth Bennet and Mr. Darcy\'s love story. A witty romance about overcoming pride, prejudice, and societal expectations.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg',
      },
      {
        'title': 'The Notebook',
        'author': 'Nicholas Sparks',
        'isbn': '978-0446605236',
        'category': 'Romance',
        'description': 'Noah and Allie\'s epic love story that spans decades. A tale of enduring love, second chances, and the power of true devotion.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780446605236-L.jpg',
      },
      {
        'title': 'Me Before You',
        'author': 'Jojo Moyes',
        'isbn': '978-0143124542',
        'category': 'Romance',
        'description': 'Louisa becomes a caregiver for Will and their lives transform. A heart-wrenching story about love, choices, and living life to the fullest.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780143124542-L.jpg',
      },
      {
        'title': 'The Fault in Our Stars',
        'author': 'John Green',
        'isbn': '978-0142424179',
        'category': 'Romance',
        'description': 'Hazel and Augustus meet at a cancer support group. A beautiful, funny, and heartbreaking love story about two extraordinary teenagers.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780142424179-L.jpg',
      },
      {
        'title': 'Outlander',
        'author': 'Diana Gabaldon',
        'isbn': '978-0385319959',
        'category': 'Romance',
        'description': 'Claire travels through time from 1945 to 1743 Scotland. An epic romance adventure mixing history, love, and time travel.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780385319959-L.jpg',
      },
      
      // Dystopian & Sci-Fi Stories
      {
        'title': 'The Hunger Games',
        'author': 'Suzanne Collins',
        'isbn': '978-0439023481',
        'category': 'Science Fiction',
        'description': 'Katniss volunteers for the deadly Hunger Games. A thrilling dystopian tale of survival, rebellion, and sacrifice in a brutal future.',
        'availableCopies': 5,
        'totalCopies': 5,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780439023481-L.jpg',
      },
      {
        'title': 'Divergent',
        'author': 'Veronica Roth',
        'isbn': '978-0062024039',
        'category': 'Science Fiction',
        'description': 'Tris must hide her Divergent nature in a faction-based society. Action-packed story about identity, courage, and revolution.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780062024039-L.jpg',
      },
      {
        'title': 'The Maze Runner',
        'author': 'James Dashner',
        'isbn': '978-0385737951',
        'category': 'Science Fiction',
        'description': 'Thomas wakes up in a mysterious maze with no memory. Can he and the other Gladers escape? Intense thriller with shocking twists!',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780385737951-L.jpg',
      },
      {
        'title': 'Ready Player One',
        'author': 'Ernest Cline',
        'isbn': '978-0307887443',
        'category': 'Science Fiction',
        'description': 'In 2045, Wade hunts for an Easter egg in a virtual reality world. Thrilling adventure filled with 80s pop culture and gaming!',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780307887443-L.jpg',
      },
      {
        'title': 'Ender\'s Game',
        'author': 'Orson Scott Card',
        'isbn': '978-0812550702',
        'category': 'Science Fiction',
        'description': 'Brilliant child Ender trains at Battle School to fight aliens. A gripping sci-fi story about war, strategy, and morality.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780812550702-L.jpg',
      },
      
      // Horror & Thriller Stories
      {
        'title': 'The Shining',
        'author': 'Stephen King',
        'isbn': '978-0307743657',
        'category': 'Horror',
        'description': 'Jack Torrance becomes winter caretaker of the isolated Overlook Hotel. Terrifying psychological horror as the hotel\'s dark forces emerge.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780307743657-L.jpg',
      },
      {
        'title': 'It',
        'author': 'Stephen King',
        'isbn': '978-1501142970',
        'category': 'Horror',
        'description': 'Seven friends battle an evil entity that preys on children. Epic horror spanning decades with terrifying encounters with Pennywise the Clown.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781501142970-L.jpg',
      },
      {
        'title': 'Dracula',
        'author': 'Bram Stoker',
        'isbn': '978-0141439846',
        'category': 'Horror',
        'description': 'The classic vampire tale. Count Dracula comes to England seeking new blood. Gothic horror that defined the vampire genre!',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780141439846-L.jpg',
      },
      {
        'title': 'The Silence of the Lambs',
        'author': 'Thomas Harris',
        'isbn': '978-0312924584',
        'category': 'Thriller',
        'description': 'FBI trainee Clarice seeks help from imprisoned cannibal Dr. Hannibal Lecter. Chilling psychological thriller that will keep you on edge!',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780312924584-L.jpg',
      },
      
      // Coming-of-Age Stories
      {
        'title': 'The Perks of Being a Wallflower',
        'author': 'Stephen Chbosky',
        'isbn': '978-1451696196',
        'category': 'Fiction',
        'description': 'Charlie\'s letters chronicle his freshman year. Touching story about friendship, love, loss, and finding yourself in high school.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781451696196-L.jpg',
      },
      {
        'title': 'Wonder',
        'author': 'R.J. Palacio',
        'isbn': '978-0375869020',
        'category': 'Fiction',
        'description': 'Auggie Pullman has facial differences and starts school for the first time. Inspiring story about kindness, acceptance, and courage.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780375869020-L.jpg',
      },
      {
        'title': 'The Outsiders',
        'author': 'S.E. Hinton',
        'isbn': '978-0142407332',
        'category': 'Fiction',
        'description': 'Ponyboy and the Greasers navigate gang rivalry and social class. Classic coming-of-age story about loyalty, family, and staying gold.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780142407332-L.jpg',
      },
      
      // Historical Fiction
      {
        'title': 'The Diary of a Young Girl',
        'author': 'Anne Frank',
        'isbn': '978-0553296983',
        'category': 'History',
        'description': 'Anne Frank\'s real diary while hiding from the Nazis. Powerful, moving account of hope and resilience during the Holocaust.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780553296983-L.jpg',
      },
      {
        'title': 'All the Light We Cannot See',
        'author': 'Anthony Doerr',
        'isbn': '978-1476746586',
        'category': 'Fiction',
        'description': 'A blind French girl and German boy\'s lives collide in WWII. Beautifully written story of humanity, courage, and hope amid war.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781476746586-L.jpg',
      },
      {
        'title': 'The Help',
        'author': 'Kathryn Stockett',
        'isbn': '978-0425232200',
        'category': 'Fiction',
        'description': 'Black maids in 1960s Mississippi share their stories. Powerful tale of courage, friendship, and fighting for change during the civil rights era.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780425232200-L.jpg',
      },
      
      // Sri Lankan Literature
      {
        'title': 'Madol Duwa',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556651058',
        'category': 'Fiction',
        'description': 'A timeless Sri Lankan classic about young Upali who runs away from home to live on a small island (Madol Duwa) in the Koggala Lake. This beloved coming-of-age story captures the spirit of adventure, freedom, and the beauty of Sri Lankan village life. Written by the legendary Martin Wickramasinghe, it\'s a tale of childhood dreams, friendship, and discovering one\'s place in the world.',
        'availableCopies': 5,
        'totalCopies': 5,
        'coverUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Madol_Doova.jpg/220px-Madol_Doova.jpg',
      },
      {
        'title': 'Viragaya',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556651133',
        'category': 'Fiction',
        'description': 'Another masterpiece by Martin Wickramasinghe. This novel explores the inner conflict of Aravinda, a young man torn between tradition and modernity, passion and duty. A profound psychological exploration of human nature set in early 20th century Sri Lanka.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/I/51xvLZL8h9L._SX331_BO1,204,203,200_.jpg',
      },
      {
        'title': 'Gamperaliya',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556651041',
        'category': 'Fiction',
        'description': 'The first novel in Wickramasinghe\'s celebrated trilogy depicting the changes in Sri Lankan society from feudalism to capitalism. The story of the Korawakka family and their struggle with changing times. A powerful social commentary wrapped in compelling storytelling.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/I/41S0Z3GVMRL._SX331_BO1,204,203,200_.jpg',
      },
      {
        'title': 'Kaliyugaya',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556651126',
        'category': 'Fiction',
        'description': 'The second book in the Korawakka trilogy. "The Age of Kali" portrays the moral and social decay of the family during the colonial period. A gripping tale of how Western influence and capitalism transform traditional Sri Lankan society.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/I/41GCQY6KVYL._SX331_BO1,204,203,200_.jpg',
      },
      {
        'title': 'Yuganthaya',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556651140',
        'category': 'Fiction',
        'description': 'The final installment of the trilogy. "The End of an Era" completes the epic saga of the Korawakka family, showing their ultimate decline and the end of feudal aristocracy in Sri Lanka. A masterful conclusion to this historical epic.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://images-na.ssl-images-amazon.com/images/I/41YS7NXJY7L._SX331_BO1,204,203,200_.jpg',
      },
      {
        'title': 'Maname',
        'author': 'Kumaratunga Munidasa',
        'isbn': '978-9558907634',
        'category': 'Fiction',
        'description': 'A poetic masterpiece by the father of Sinhala language revival. This romantic novel tells the story of Jinadasa and Siriyalatha, exploring themes of love, loss, and the essence of Sri Lankan culture. Written in beautiful, pure Sinhala prose.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/03/MANAME.jpg',
      },
      {
        'title': 'Hevanella',
        'author': 'W.A. Silva',
        'isbn': '978-9556652123',
        'category': 'Fiction',
        'description': 'A touching story about Hevanella, a village girl whose life changes when she moves to the city. This novel beautifully captures rural Sri Lankan life and the challenges of adapting to urban society. A tale of innocence, love, and social transformation.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/05/HEVANALLA.jpg',
      },
      {
        'title': 'Kurulu Hadaya',
        'author': 'W.A. Silva',
        'isbn': '978-9556652245',
        'category': 'Fiction',
        'description': 'A romantic novel about a young woman\'s journey through love and heartbreak. Set against the backdrop of Sri Lankan society, it explores themes of sacrifice, duty, and the conflicts between personal desires and social expectations.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/06/KURULU-HADAYA.jpg',
      },
      {
        'title': 'Arachchi Malli',
        'author': 'G.B. Senanayake',
        'isbn': '978-9558908341',
        'category': 'Fiction',
        'description': 'A humorous and satirical novel about village life in colonial Sri Lanka. The story of Arachchi Malli and his adventures provides both entertainment and social commentary on the clash between traditional and colonial systems.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/01/ARACHCHI-MALLI.jpg',
      },
      {
        'title': 'Rohini',
        'author': 'W.A. Silva',
        'isbn': '978-9556652450',
        'category': 'Romance',
        'description': 'A classic Sri Lankan romance novel about the beautiful Rohini and her forbidden love. Set in rural Ceylon, this emotional tale explores themes of class, tradition, and the power of true love against all odds.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/07/ROHINI.jpg',
      },
      {
        'title': 'Nuramali',
        'author': 'Piyadasa Sirisena',
        'isbn': '978-9558907559',
        'category': 'Fiction',
        'description': 'One of the earliest Sinhala novels, written by pioneer Piyadasa Sirisena. A social reform novel that critiques the evils of alcohol and advocates for Buddhist values. A landmark in Sri Lankan literary history.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/02/NURAMALI.jpg',
      },
      {
        'title': 'Kalukondayage Minis Isuru',
        'author': 'K. Jayatilaka',
        'isbn': '978-9558908563',
        'category': 'Fiction',
        'description': 'A powerful novel about the struggles of the working class in Sri Lanka. The story of Kalukondaya, a laborer, and his family\'s fight for dignity and survival. A moving portrayal of poverty and resilience.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/03/KALUKONDAYAGE.jpg',
      },
      {
        'title': 'Hath Pana',
        'author': 'Kumaratunga Munidasa',
        'isbn': '978-9558907672',
        'category': 'Fiction',
        'description': 'A classic tale of seven brothers and their adventures. Written by the legendary language reformer Kumaratunga Munidasa, this story combines folklore, morality, and beautiful Sinhala prose. A treasured work of Sri Lankan literature.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/04/HATH-PANA.jpg',
      },
      {
        'title': 'Dadayama',
        'author': 'W.A. Silva',
        'isbn': '978-9556652788',
        'category': 'Fiction',
        'description': 'A touching novel about the bond between parents and children. Silva\'s masterful storytelling explores family dynamics, generational conflicts, and the enduring power of parental love in Sri Lankan society.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/08/DADAYAMA.jpg',
      },
      {
        'title': 'Amba Yaluwo',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556653012',
        'category': 'Fiction',
        'description': 'A powerful political novel about Sri Lankan youth in the 1970s. This story captures the revolutionary spirit, idealism, and tragic consequences of political movements. One of Amarasekara\'s most influential works.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/05/AMBA-YALUWO.jpg',
      },
      {
        'title': 'Gamarala Gedera Gini',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556653234',
        'category': 'Fiction',
        'description': 'A compelling story about rural Sri Lankan life and the transformation of traditional society. Amarasekara explores themes of development, progress, and the loss of cultural identity.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/06/GAMARALA-GEDERA.jpg',
      },
      {
        'title': 'Karumakkarayo',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556653456',
        'category': 'Fiction',
        'description': 'A novel about labor movements and workers\' struggles in Sri Lanka. This story depicts the lives of factory workers and their fight for rights and dignity.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/07/KARUMAKKARAYO.jpg',
      },
      {
        'title': 'Yali Upannemi',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556653678',
        'category': 'Fiction',
        'description': 'A philosophical novel exploring the meaning of life and existence. Set against the backdrop of modern Sri Lanka, it questions materialism and spiritual values.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/08/YALI-UPANNEMI.jpg',
      },
      {
        'title': 'Golu Hadawatha',
        'author': 'Karunasena Jayalath',
        'isbn': '978-9556654123',
        'category': 'Romance',
        'description': 'A beautiful love story set in a Sri Lankan village. The tale of Sugath and Romanie, two young lovers facing social and family obstacles. A touching romance that became a classic film.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/09/GOLU-HADAWATHA.jpg',
      },
      {
        'title': 'Salelu Warama',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556654345',
        'category': 'Fiction',
        'description': 'A story about identity and belonging. The protagonist\'s journey to find his roots and understand his place in society. A profound exploration of cultural heritage.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/09/SALELU-WARAMA.jpg',
      },
      {
        'title': 'Hathdinnath Tharu',
        'author': 'Siri Gunasinghe',
        'isbn': '978-9556654567',
        'category': 'Fiction',
        'description': 'A modern classic exploring human relationships and moral dilemmas. Gunasinghe\'s masterful prose brings to life the complexities of modern Sri Lankan society.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/10/HATHDINNATH-THARU.jpg',
      },
      {
        'title': 'Mas Le Nathi Aran',
        'author': 'Siri Gunasinghe',
        'isbn': '978-9556654789',
        'category': 'Fiction',
        'description': 'A psychological novel about loneliness and alienation in modern life. Gunasinghe delves deep into the human psyche, exploring themes of isolation and connection.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/11/MAS-LE-NATHI.jpg',
      },
      {
        'title': 'Nomiyena Minisun',
        'author': 'Ediriweera Sarachchandra',
        'isbn': '978-9556655012',
        'category': 'Fiction',
        'description': 'A social drama about the silent majority. Sarachchandra, the father of modern Sinhala theatre, explores the lives of ordinary people and their struggles.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/12/NOMIYENA-MINISUN.jpg',
      },
      {
        'title': 'Malagiya Aththo',
        'author': 'Ediriweera Sarachchandra',
        'isbn': '978-9556655234',
        'category': 'Fiction',
        'description': 'A poignant story based on the folk tale of Maname. Sarachchandra adapts traditional stories for modern audiences, exploring timeless themes of love and duty.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/01/MALAGIYA-ATHTHO.jpg',
      },
      {
        'title': 'Diyamanthi',
        'author': 'Simon Nawagattegama',
        'isbn': '978-9556655456',
        'category': 'Romance',
        'description': 'A romantic tale of love conquering all obstacles. Diyamanthi and her lover face family opposition and social barriers in their quest for happiness.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/10/DIYAMANTHI.jpg',
      },
      {
        'title': 'Awaree',
        'author': 'Cyril C. Perera',
        'isbn': '978-9556655678',
        'category': 'Fiction',
        'description': 'A gripping tale of crime and punishment in colonial Ceylon. This novel explores the dark side of society and the quest for justice.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/02/AWAREE.jpg',
      },
      {
        'title': 'Kinihiriya Mal',
        'author': 'Sunil Shantha',
        'isbn': '978-9556656012',
        'category': 'Romance',
        'description': 'A beautiful romance set in the tea plantations. The love story between a plantation worker and a supervisor\'s daughter unfolds amidst lush greenery.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/11/KINIHIRIYA-MAL.jpg',
      },
      {
        'title': 'Anthima Satana',
        'author': 'Upali Dassanaike',
        'isbn': '978-9556656234',
        'category': 'Fiction',
        'description': 'A novel about death and dying, exploring Buddhist philosophy and the impermanence of life. A profound meditation on mortality and meaning.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/03/ANTHIMA-SATANA.jpg',
      },
      {
        'title': 'Dhawala Bheeshana',
        'author': 'Munidasa Cumaratunga',
        'isbn': '978-9556656456',
        'category': 'Fiction',
        'description': 'A horror story rooted in Sri Lankan folklore and supernatural beliefs. Cumaratunga weaves traditional ghost stories into a modern narrative.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/04/DHAWALA-BHEESHANA.jpg',
      },
      {
        'title': 'Sepalika Malak Wage',
        'author': 'Namel Weeramunda',
        'isbn': '978-9556656678',
        'category': 'Romance',
        'description': 'A sweet romance comparing love to the fragrant sepalika flower. This tender story explores first love and youthful innocence.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2019/12/SEPALIKA-MALAK.jpg',
      },
      {
        'title': 'Apahu Uyanne Na',
        'author': 'Karunaratne Abeysekara',
        'isbn': '978-9556657012',
        'category': 'Fiction',
        'description': 'A story about reconciliation and forgiveness. Set in post-independence Sri Lanka, it explores healing from past wounds.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/05/APAHU-UYANNE.jpg',
      },
      {
        'title': 'Thurya',
        'author': 'Mahagama Sekara',
        'isbn': '978-9556657234',
        'category': 'Fiction',
        'description': 'A poetic novel by the celebrated poet Mahagama Sekara. This lyrical story blends poetry and prose to create a unique literary experience.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/06/THURYA.jpg',
      },
      {
        'title': 'Ran Kivuli',
        'author': 'Simon Navagattegama',
        'isbn': '978-9556657456',
        'category': 'Romance',
        'description': 'A tragic love story set against the backdrop of Sri Lankan aristocracy. The golden ladder of social climbing leads to heartbreak and redemption.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/01/RAN-KIVULI.jpg',
      },
      {
        'title': 'Sooriya Arana',
        'author': 'Ediriweera Sarachchandra',
        'isbn': '978-9556657678',
        'category': 'Fiction',
        'description': 'A historical novel set in ancient Sri Lanka during the time of kings. Sarachchandra brings history to life with vivid characters and dramatic events.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/07/SOORIYA-ARANA.jpg',
      },
      {
        'title': 'Kala Kalapuwa',
        'author': 'K. Jayatilaka',
        'isbn': '978-9556658012',
        'category': 'Fiction',
        'description': 'A mystery novel set in the lagoons of Sri Lanka. Dark secrets and hidden truths emerge from the black waters.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/08/KALA-KALAPUWA.jpg',
      },
      {
        'title': 'Podi Putha',
        'author': 'W.A. Silva',
        'isbn': '978-9556658234',
        'category': 'Fiction',
        'description': 'A touching story about a young boy growing up in rural Sri Lanka. Silva captures the innocence of childhood and the harsh realities of life.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/02/PODI-PUTHA.jpg',
      },
      {
        'title': 'Salpathya',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556658456',
        'category': 'Fiction',
        'description': 'A novel about political corruption and moral decay. Amarasekara critiques the post-independence political system and its failures.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/09/SALPATHYA.jpg',
      },
      {
        'title': 'Weli Amma',
        'author': 'K.D. Caldera',
        'isbn': '978-9556658678',
        'category': 'Fiction',
        'description': 'A story about a devoted mother\'s sacrifice for her children. This emotional tale celebrates maternal love and family bonds.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/03/WELI-AMMA.jpg',
      },
      {
        'title': 'Sunila',
        'author': 'W.A. Silva',
        'isbn': '978-9556659012',
        'category': 'Romance',
        'description': 'A romantic drama about Sunila, a beautiful young woman caught between love and duty. Silva\'s masterful characterization brings this story to life.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/04/SUNILA.jpg',
      },
      {
        'title': 'Nisadas Wela',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556659234',
        'category': 'Fiction',
        'description': 'A novel about fishing communities and their way of life. Amarasekara explores the struggles of coastal people and environmental changes.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/10/NISADAS-WELA.jpg',
      },
      {
        'title': 'Pitagamkarayo',
        'author': 'W.A. Silva',
        'isbn': '978-9556659456',
        'category': 'Fiction',
        'description': 'A tale of village life and the people who make it vibrant. Silva paints a warm portrait of rural Sri Lankan community and traditions.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/05/PITAGAMKARAYO.jpg',
      },
      {
        'title': 'Sada Sulang',
        'author': 'Simon Navagattegama',
        'isbn': '978-9556659678',
        'category': 'Romance',
        'description': 'An eternal love story that transcends time and social boundaries. A romantic masterpiece celebrating the power of true love.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/06/SADA-SULANG.jpg',
      },
      {
        'title': 'Dharani',
        'author': 'Jinadasa Wijayatunga',
        'isbn': '978-9556660123',
        'category': 'Fiction',
        'description': 'A novel about connection to the land and environmental consciousness. The story of people fighting to preserve their ancestral soil.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/11/DHARANI.jpg',
      },
      {
        'title': 'Pembara Walalu',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556660345',
        'category': 'Fiction',
        'description': 'A collection of interconnected short stories about village life. Wickramasinghe\'s keen observation brings these characters to vivid life.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/07/PEMBARA-WALALU.jpg',
      },
      {
        'title': 'Giraya',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556660567',
        'category': 'Fiction',
        'description': 'A powerful story about pride and its consequences. Wickramasinghe explores human nature and the price of arrogance.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/12/GIRAYA.jpg',
      },
      {
        'title': 'Chandali',
        'author': 'W.A. Silva',
        'isbn': '978-9556660789',
        'category': 'Fiction',
        'description': 'A novel about caste discrimination and social justice. Silva tackles difficult social issues with sensitivity and insight.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/08/CHANDALI.jpg',
      },
      {
        'title': 'Yakada Yaka',
        'author': 'Kumaratunga Munidasa',
        'isbn': '978-9556661012',
        'category': 'Fiction',
        'description': 'A folktale-inspired novel about demons and supernatural beings. Munidasa weaves traditional Sri Lankan folklore into an engaging story.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/01/YAKADA-YAKA.jpg',
      },
      {
        'title': 'Sandakada Pahana',
        'author': 'Siri Gunasinghe',
        'isbn': '978-9556661234',
        'category': 'Fiction',
        'description': 'A novel exploring Buddhist philosophy through the metaphor of the moonstone. Deep spiritual insights wrapped in compelling narrative.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/02/SANDAKADA-PAHANA.jpg',
      },
      {
        'title': 'Kolamba Kathawa',
        'author': 'Jinadasa Wijayatunga',
        'isbn': '978-9556661456',
        'category': 'Fiction',
        'description': 'A story about Colombo city life and urban development. The changing face of the capital and its impact on people\'s lives.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/03/KOLAMBA-KATHAWA.jpg',
      },
      {
        'title': 'Sudu Sevanali',
        'author': 'Simon Navagattegama',
        'isbn': '978-9556661678',
        'category': 'Romance',
        'description': 'A poetic love story comparing romance to white blossoms. Navagattegama\'s lyrical prose creates a dreamlike atmosphere.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/09/SUDU-SEVANALI.jpg',
      },
      {
        'title': 'Waradakma',
        'author': 'Mahagama Sekara',
        'isbn': '978-9556662012',
        'category': 'Fiction',
        'description': 'A philosophical novel about crime and redemption. Sekara explores the nature of guilt and the possibility of forgiveness.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/04/WARADAKMA.jpg',
      },
      {
        'title': 'Sath Samudura',
        'author': 'G.B. Senanayake',
        'isbn': '978-9556662234',
        'category': 'Fiction',
        'description': 'An adventure story about seafaring and exploration. The seven seas represent the journey of self-discovery.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/05/SATH-SAMUDURA.jpg',
      },
      {
        'title': 'Nalala',
        'author': 'W.A. Silva',
        'isbn': '978-9556662456',
        'category': 'Romance',
        'description': 'A tender love story about Nalala and her journey to find happiness. Silva\'s gentle storytelling touches the heart.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/10/NALALA.jpg',
      },
      {
        'title': 'Pasal Pata Uyana',
        'author': 'Karunaratne Abeysekara',
        'isbn': '978-9556662678',
        'category': 'Fiction',
        'description': 'A nostalgic novel about childhood and school days. Abeysekara captures the magic of youth and innocent friendships.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/06/PASAL-PATA.jpg',
      },
      {
        'title': 'Ranwan Korale',
        'author': 'Cyril C. Perera',
        'isbn': '978-9556663012',
        'category': 'Fiction',
        'description': 'A historical novel about the kingdom of Sitawaka and its golden era. Perera brings ancient Sri Lankan history to life.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/07/RANWAN-KORALE.jpg',
      },
      {
        'title': 'Anamika',
        'author': 'Kumaratunga Munidasa',
        'isbn': '978-9556663234',
        'category': 'Fiction',
        'description': 'A mystery about identity and anonymity. Who is the nameless one? Munidasa creates an intriguing puzzle.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/08/ANAMIKA.jpg',
      },
      {
        'title': 'Pinsara',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556663456',
        'category': 'Fiction',
        'description': 'A novel about desire and its consequences. Wickramasinghe explores human passions and moral choices.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/11/PINSARA.jpg',
      },
      {
        'title': 'Saradiel',
        'author': 'Shyam Selvanayagam',
        'isbn': '978-9556663678',
        'category': 'Fiction',
        'description': 'The legendary story of the Robin Hood of Sri Lanka. Saradiel, the gentleman bandit who stole from the rich to help the poor.',
        'availableCopies': 4,
        'totalCopies': 4,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2020/12/SARADIEL.jpg',
      },
      {
        'title': 'Sikuru Tharuwa',
        'author': 'Martin Wickramasinghe',
        'isbn': '978-9556664012',
        'category': 'Fiction',
        'description': 'The autobiography of a Sinhala novel. Wickramasinghe reflects on the art of writing and his literary journey.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/09/SIKURU-THARUWA.jpg',
      },
      {
        'title': 'Dutugemunu',
        'author': 'John Peris',
        'isbn': '978-9556664234',
        'category': 'History',
        'description': 'The epic story of King Dutugemunu who united Sri Lanka. A historical novel about heroism, war, and national pride.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/01/DUTUGEMUNU.jpg',
      },
      {
        'title': 'Nirogi',
        'author': 'W.A. Silva',
        'isbn': '978-9556664456',
        'category': 'Fiction',
        'description': 'A story about health, wellness, and the human spirit. Silva explores the connection between mind and body.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2021/02/NIROGI.jpg',
      },
      {
        'title': 'Uda Diya Nalawa',
        'author': 'Karunaratne Abeysekara',
        'isbn': '978-9556664678',
        'category': 'Fiction',
        'description': 'A novel about aspirations and upward mobility. The story of those who dare to dream beyond their circumstances.',
        'availableCopies': 3,
        'totalCopies': 3,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/10/UDA-DIYA-NALAWA.jpg',
      },
      {
        'title': 'Vana Bambaru',
        'author': 'Gunadasa Amarasekara',
        'isbn': '978-9556665012',
        'category': 'Fiction',
        'description': 'A story about forest conservation and the conflict between development and environment. Amarasekara\'s environmental consciousness shines through.',
        'availableCopies': 2,
        'totalCopies': 2,
        'coverUrl': 'https://www.sarasaviya.lk/wp-content/uploads/2022/11/VANA-BAMBARU.jpg',
      },
    ];

    for (var book in books) {
      await FirebaseFirestore.instance.collection('books').add({
        ...book,
        'available': (book['availableCopies'] as int) > 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Add sample borrowed books for testing
  static Future<void> addSampleBorrowedBooks(String userId) async {
    try {
      // First, get some books from the database
      final booksSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .limit(5)
          .get();

      if (booksSnapshot.docs.isEmpty) {
        throw Exception('No books found. Please add sample books first.');
      }

      final now = DateTime.now();
      
      // Add 3 borrowed books (not yet returned)
      for (int i = 0; i < 3 && i < booksSnapshot.docs.length; i++) {
        final bookDoc = booksSnapshot.docs[i];
        final bookId = bookDoc.id;
        final bookData = bookDoc.data();
        
        await FirebaseFirestore.instance.collection('borrowedBooks').add({
          'userId': userId,
          'bookId': bookId,
          'bookTitle': bookData['title'],
          'bookAuthor': bookData['author'],
          'borrowedDate': Timestamp.fromDate(now.subtract(Duration(days: 7 + i * 2))),
          'dueDate': Timestamp.fromDate(now.add(Duration(days: 7 - i * 2))),
          'isReturned': false,
        });

        // Update book availability
        int availableCopies = bookData['availableCopies'] ?? 0;
        if (availableCopies > 0) {
          await FirebaseFirestore.instance
              .collection('books')
              .doc(bookId)
              .update({
            'availableCopies': availableCopies - 1,
          });
        }
      }

      // Add 2 returned books
      for (int i = 3; i < 5 && i < booksSnapshot.docs.length; i++) {
        final bookDoc = booksSnapshot.docs[i];
        final bookId = bookDoc.id;
        final bookData = bookDoc.data();
        
        final borrowDate = now.subtract(Duration(days: 30 + i * 5));
        final returnDate = borrowDate.add(const Duration(days: 10));
        
        await FirebaseFirestore.instance.collection('borrowedBooks').add({
          'userId': userId,
          'bookId': bookId,
          'bookTitle': bookData['title'],
          'bookAuthor': bookData['author'],
          'borrowedDate': Timestamp.fromDate(borrowDate),
          'dueDate': Timestamp.fromDate(borrowDate.add(const Duration(days: 14))),
          'returnedDate': Timestamp.fromDate(returnDate),
          'isReturned': true,
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Borrow Requests Screen
class BorrowRequestsScreen extends StatefulWidget {
  const BorrowRequestsScreen({super.key});

  @override
  State<BorrowRequestsScreen> createState() => _BorrowRequestsScreenState();
}

class _BorrowRequestsScreenState extends State<BorrowRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Borrow Requests',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: StreamBuilder<List<BorrowedBook>>(
        stream: bookProvider.getPendingBorrowRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // StreamBuilder handles real-time updates automatically
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                    request.bookTitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${request.bookAuthor}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Requested: ${_formatDate(request.borrowedDate)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'User ID: ${request.userId.substring(0, 8)}...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Approve Request',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        'Approve borrow request for "${request.bookTitle}"?',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('Approve'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    final success = await bookProvider
                                        .approveBorrowRequest(
                                            request.id, request.bookId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Request approved!'
                                                : 'Failed to approve request',
                                          ),
                                          backgroundColor: success
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      );
                                      setState(() {});
                                    }
                                  }
                                },
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Reject Request',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      content: Text(
                                        'Reject borrow request for "${request.bookTitle}"?',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    final success = await bookProvider
                                        .rejectBorrowRequest(request.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Request rejected'
                                                : 'Failed to reject request',
                                          ),
                                          backgroundColor: success
                                              ? Colors.orange
                                              : Colors.red,
                                        ),
                                      );
                                      setState(() {});
                                    }
                                  }
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Track Borrowers Screen
class TrackBorrowersScreen extends StatefulWidget {
  const TrackBorrowersScreen({super.key});

  @override
  State<TrackBorrowersScreen> createState() => _TrackBorrowersScreenState();
}

class _TrackBorrowersScreenState extends State<TrackBorrowersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBorrowers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Search for borrowed books by book title
      final borrowedBooksQuery = await FirebaseFirestore.instance
          .collection('borrowedBooks')
          .where('isReturned', isEqualTo: false)
          .where('status', isEqualTo: 'approved')
          .get();

      final results = <Map<String, dynamic>>[];

      for (var doc in borrowedBooksQuery.docs) {
        final data = doc.data();
        final bookTitle = data['bookTitle'] ?? '';
        
        if (bookTitle.toLowerCase().contains(query.toLowerCase())) {
          // Get user details
          final userId = data['userId'];
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          
          final userData = userDoc.data();
          
          results.add({
            'borrowId': doc.id,
            'bookId': data['bookId'],
            'bookTitle': bookTitle,
            'bookAuthor': data['bookAuthor'] ?? 'Unknown Author',
            'borrowedDate': (data['borrowedDate'] as Timestamp).toDate(),
            'dueDate': (data['dueDate'] as Timestamp).toDate(),
            'userId': userId,
            'userName': userData?['displayName'] ?? 'Unknown User',
            'userEmail': userData?['email'] ?? 'No email',
            'userPhone': userData?['phone'] ?? 'No phone',
            'userAddress': userData?['address'] ?? 'No address',
            'studentIndex': userData?['studentIndex'] ?? 'N/A',
          });
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showBorrowerDetails(Map<String, dynamic> borrower) async {
    final isOverdue = DateTime.now().isAfter(borrower['dueDate']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Borrower Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Information
              Text(
                'Book Information',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Title', borrower['bookTitle']),
              _buildInfoRow('Author', borrower['bookAuthor']),
              _buildInfoRow(
                'Borrowed',
                _formatDate(borrower['borrowedDate']),
              ),
              _buildInfoRow(
                'Due Date',
                _formatDate(borrower['dueDate']),
                isOverdue ? Colors.red : null,
              ),
              if (isOverdue)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              const Divider(height: 24),
              
              // User Information
              Text(
                'Borrower Information',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Name', borrower['userName']),
              _buildInfoRow('Student Index', borrower['studentIndex']),
              _buildInfoRow('Email', borrower['userEmail']),
              _buildInfoRow('Phone', borrower['userPhone']),
              _buildInfoRow('Address', borrower['userAddress']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (borrower['userPhone'] != 'No phone')
            ElevatedButton.icon(
              onPressed: () {
                // Copy phone to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Phone copied: ${borrower['userPhone']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.phone),
              label: const Text('Copy Phone'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Borrowers',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal,
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by book title...',
                hintStyle: GoogleFonts.poppins(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
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
                _searchBorrowers(value);
              },
            ),
          ),
          
          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Search for a book to find who borrowed it'
                                  : 'No borrowed books found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final borrower = _searchResults[index];
                          final isOverdue = DateTime.now().isAfter(borrower['dueDate']);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isOverdue ? Colors.red : Colors.grey[300]!,
                                width: isOverdue ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showBorrowerDetails(borrower),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
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
                                                borrower['bookTitle'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'by ${borrower['bookAuthor']}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isOverdue)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'OVERDUE',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_rounded,
                                          size: 18,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            borrower['userName'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.badge_rounded,
                                          size: 18,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          borrower['studentIndex'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.phone_rounded,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          borrower['userPhone'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Due: ${_formatDate(borrower['dueDate'])}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: isOverdue ? Colors.red : Colors.grey[600],
                                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
