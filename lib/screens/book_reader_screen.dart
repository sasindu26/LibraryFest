import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';

class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  double _fontSize = 16.0;
  double _lineHeight = 1.6;

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.book.fullContent != null && widget.book.fullContent!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5), // Warm reading background
      appBar: AppBar(
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Font size controls
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields_rounded, color: Colors.white),
            onSelected: (value) {
              setState(() {
                if (value == 'increase') {
                  _fontSize = (_fontSize + 2).clamp(12.0, 28.0);
                } else if (value == 'decrease') {
                  _fontSize = (_fontSize - 2).clamp(12.0, 28.0);
                } else if (value == 'line_increase') {
                  _lineHeight = (_lineHeight + 0.2).clamp(1.2, 2.4);
                } else if (value == 'line_decrease') {
                  _lineHeight = (_lineHeight - 0.2).clamp(1.2, 2.4);
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'increase',
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, size: 20),
                    const SizedBox(width: 12),
                    Text('Increase Font Size', style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'decrease',
                child: Row(
                  children: [
                    const Icon(Icons.remove_circle_outline, size: 20),
                    const SizedBox(width: 12),
                    Text('Decrease Font Size', style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'line_increase',
                child: Row(
                  children: [
                    const Icon(Icons.format_line_spacing, size: 20),
                    const SizedBox(width: 12),
                    Text('Increase Line Spacing', style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'line_decrease',
                child: Row(
                  children: [
                    const Icon(Icons.format_line_spacing, size: 20),
                    const SizedBox(width: 12),
                    Text('Decrease Line Spacing', style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: hasContent
          ? _buildReaderView()
          : _buildNoContentView(),
    );
  }

  Widget _buildReaderView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Title
          Text(
            widget.book.title,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Author
          Text(
            'by ${widget.book.author}',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Divider
          Container(
            height: 2,
            width: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 32),
          // Full Book Content
          SelectableText(
            widget.book.fullContent!,
            style: GoogleFonts.literata(
              fontSize: _fontSize,
              height: _lineHeight,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 60),
          // End marker
          Center(
            child: Column(
              children: [
                Container(
                  height: 2,
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '— THE END —',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNoContentView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
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
                Icons.menu_book_rounded,
                size: 80,
                color: const Color(0xFFFF9500).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Content Not Available',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'The full content for this book is not available yet.\n\nPlease contact the admin to add the book content.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(
                'Go Back',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
