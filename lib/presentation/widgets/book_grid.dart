import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/widgets/chapter_selection_dialog.dart';

class BookGrid extends StatelessWidget {
  final List<BookModel> books;
  final VoidCallback onChapterSelected;

  const BookGrid({
    super.key,
    required this.books,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (books.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("Tsy misy boky hita", style: TextStyle(fontSize: 11)),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 2.1,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final catColor = _getBookCategoryColor(book.number);
        return InkWell(
          onTap: () => _showChapters(context, book),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  catColor.withOpacity(0.12),
                  catColor.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: catColor.withOpacity(0.2),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: catColor.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      book.name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.colorScheme.onSurface,
                      ),
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

  Color _getBookCategoryColor(int bookNumber) {
    if (bookNumber <= 5) return const Color(0xFFE53935); // Pentateuch - Red
    if (bookNumber <= 17) return const Color(0xFFFB8C00); // Historical - Orange
    if (bookNumber <= 22) return const Color(0xFF00ACC1); // Poetic - Cyan
    if (bookNumber <= 39) return const Color(0xFF8E24AA); // Prophets - Purple
    if (bookNumber <= 43) return const Color(0xFF43A047); // Gospels - Green
    if (bookNumber == 44) return const Color(0xFF1976D2); // Acts - Blue
    if (bookNumber <= 65) return const Color(0xFFD81B60); // Epistles - Pink
    return const Color(0xFF795548); // Revelation - Brown
  }

  void _showChapters(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollController) => ChapterSelectionDialog(
            book: book,
            onChapterSelected: onChapterSelected,
          ),
        );
      },
    );
  }
}
