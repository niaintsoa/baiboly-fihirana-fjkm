import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class ChapterSelectionDialog extends StatefulWidget {
  final BookModel book;
  final VoidCallback onChapterSelected;

  const ChapterSelectionDialog({super.key, required this.book, required this.onChapterSelected});

  @override
  State<ChapterSelectionDialog> createState() => _ChapterSelectionDialogState();
}

class _ChapterSelectionDialogState extends State<ChapterSelectionDialog> {
  int? _selectedChapter;
  int _versesCount = 0;
  bool _isLoading = false;

  Future<void> _loadVerses(int chapter) async {
    setState(() {
      _selectedChapter = chapter;
      _isLoading = true;
    });
    try {
      final repo = context.read<BibleRepository>();
      final verses = await repo.getVerses(widget.book.number, chapter);
      setState(() {
        _versesCount = verses.length;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChapterStep = _selectedChapter == null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isChapterStep)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 18),
                    onPressed: () => setState(() => _selectedChapter = null),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                Text(
                  isChapterStep ? "Safidio ny toko (${widget.book.name})" : "Safidio ny andininy (Toko $_selectedChapter)",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 8),
          if (_isLoading)
            const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 6, mainAxisSpacing: 6),
                itemCount: isChapterStep ? widget.book.totalChapters : _versesCount,
                itemBuilder: (context, index) {
                  final number = index + 1;
                  return InkWell(
                    onTap: () {
                      if (isChapterStep) {
                        _loadVerses(number);
                      } else {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          NoAnimationPageRoute(
                            builder: (_) => ReaderScreen(book: widget.book, initialChapter: _selectedChapter!, initialVerse: number),
                          ),
                        ).then((_) => widget.onChapterSelected());
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
                      ),
                      child: Center(
                        child: Text(
                          "$number",
                          style: theme.textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
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
}
