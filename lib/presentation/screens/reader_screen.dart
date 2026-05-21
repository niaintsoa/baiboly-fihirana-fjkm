import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/presentation/cubits/bible_reader_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/verse_list_view.dart';
import 'package:baiboly_apk/presentation/widgets/theme_settings_sheet.dart';
import 'package:baiboly_apk/presentation/cubits/history_cubit.dart';
import 'package:baiboly_apk/data/models/history_item.dart';

class ReaderScreen extends StatefulWidget {
  final BookModel book;
  final int initialChapter;
  final int? initialVerse;
  final int? initialEndVerse;

  const ReaderScreen({
    super.key,
    required this.book,
    required this.initialChapter,
    this.initialVerse,
    this.initialEndVerse,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PageController _pageController;
  late int _currentChapter;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _pageController = PageController(initialPage: _currentChapter - 1);
    // If initialVerse is provided, we start with showing only that verse (or range)
    _showAll = widget.initialVerse == null;
    _loadChapterData(_currentChapter);
    context.read<BookmarkCubit>().loadBookmarks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadChapterData(int chapter) {
    context.read<BibleReaderCubit>().loadChapter(widget.book, chapter);
    _saveLastRead(chapter);
  }

  Future<void> _saveLastRead(int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_book_number', widget.book.number);
    await prefs.setInt('last_read_chapter', chapter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => Navigator.pop(context)),
        title: BlocBuilder<BibleReaderCubit, BibleReaderState>(
          builder: (context, state) {
            String title = widget.book.name;
            if (state is BibleReaderLoaded) title = "${state.currentBook.name} $_currentChapter";
            return Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold));
          },
        ),
        actions: [
          if (widget.initialVerse != null)
            IconButton(
              icon: Icon(
                _showAll ? Icons.visibility : Icons.visibility_off,
                size: 18,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() => _showAll = !_showAll);
                // When toggling to show all, we still stay on same chapter; the builder will use _showAll flag.
                // No need to reload chapter data because the verses are already loaded; we just change filtering.
              },
            ),
          IconButton(icon: const Icon(Icons.text_fields, size: 20), onPressed: () => _showSettings()),
        ],
      ),
      body: BlocListener<BibleReaderCubit, BibleReaderState>(
        listener: (context, state) {
          if (state is BibleReaderLoaded) {
            if (state.verses.isNotEmpty) {
              final int targetVerse;
              final String targetText;
              if (state.currentChapter == widget.initialChapter && widget.initialVerse != null) {
                targetVerse = widget.initialVerse!;
                final verseObj = state.verses.firstWhere(
                  (v) => v.verse == targetVerse,
                  orElse: () => state.verses.first,
                );
                targetText = verseObj.text;
              } else {
                targetVerse = 1;
                targetText = state.verses.first.text;
              }

              final historyItem = HistoryItem(
                bookNumber: state.currentBook.number,
                bookName: state.currentBook.name,
                chapter: state.currentChapter,
                verse: targetVerse,
                text: targetText,
              );
              context.read<HistoryCubit>().addItem(historyItem);
            }
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.book.totalChapters,
          onPageChanged: (idx) {
            setState(() => _currentChapter = idx + 1);
            _loadChapterData(_currentChapter);
          },
          itemBuilder: (context, idx) {
            final chIdx = idx + 1;
             return BlocBuilder<BibleReaderCubit, BibleReaderState>(
               builder: (context, state) {
                 if (state is BibleReaderLoading) return const Center(child: CircularProgressIndicator());
                  if (state is BibleReaderLoaded && state.currentChapter == chIdx) {
                    List<VerseModel> versesToShow = state.verses;
                    if (chIdx == widget.initialChapter && !_showAll && widget.initialVerse != null) {
                      int start = widget.initialVerse!;
                      int end = widget.initialEndVerse ?? widget.initialVerse!;
                      versesToShow = state.verses.where((v) => v.verse >= start && v.verse <= end).toList();
                    }
                    return VerseListView(
                      verses: versesToShow,
                      initialVerse: chIdx == widget.initialChapter && !_showAll ? widget.initialVerse : null,
                      initialEndVerse: chIdx == widget.initialChapter && !_showAll ? widget.initialEndVerse : null,
                    );
                  }
                 if (state is BibleReaderError) return Center(child: Text(state.message, style: const TextStyle(fontSize: 12)));
                 return const SizedBox.shrink();
               },
             );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.surface, border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentChapter > 1 ? () => _pageController.previousPage(duration: const Duration(milliseconds: 1), curve: Curves.linear) : null,
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
          Text("Toko $_currentChapter / ${widget.book.totalChapters}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
          IconButton(
            onPressed: _currentChapter < widget.book.totalChapters ? () => _pageController.nextPage(duration: const Duration(milliseconds: 1), curve: Curves.linear) : null,
            icon: const Icon(Icons.arrow_forward, size: 20),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
      builder: (_) => const ThemeSettingsSheet(),
    );
  }
}
