import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/cubits/bible_reader_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/verse_list_view.dart';
import 'package:baiboly_apk/presentation/widgets/reader_settings_sheet.dart';

class ReaderScreen extends StatefulWidget {
  final BookModel book;
  final int initialChapter;

  const ReaderScreen({super.key, required this.book, required this.initialChapter});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PageController _pageController;
  late int _currentChapter;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _pageController = PageController(initialPage: _currentChapter - 1);
    _loadChapterData(_currentChapter);
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
          IconButton(icon: const Icon(Icons.text_fields, size: 20), onPressed: () => _showSettings()),
        ],
      ),
      body: PageView.builder(
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
                return VerseListView(verses: state.verses);
              }
              if (state is BibleReaderError) return Center(child: Text(state.message, style: const TextStyle(fontSize: 12)));
              return const SizedBox.shrink();
            },
          );
        },
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
      builder: (_) => const ReaderSettingsSheet(),
    );
  }
}
