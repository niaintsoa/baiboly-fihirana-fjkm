import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/widgets/bookmark_tile.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookmarkCubit>().loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("Andininy Tianao", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarkLoading) return const Center(child: CircularProgressIndicator());
          if (state is BookmarkLoaded) {
            final bookmarks = state.bookmarks;
            if (bookmarks.isEmpty) return _buildEmptyState(theme);
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return BookmarkTile(
                  bookmark: bookmark,
                  onTap: () {
                    final verse = VerseModel(
                      id: bookmark.id,
                      bookNumber: bookmark.bookNumber,
                      bookName: bookmark.bookName,
                      chapter: bookmark.chapter,
                      verse: bookmark.verse,
                      text: bookmark.text,
                    );
                    _navigateToReader(verse);
                  },
                );
              },
            );
          }
          if (state is BookmarkError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 12)));
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 40, color: theme.colorScheme.primary.withOpacity(0.15)),
            const SizedBox(height: 8),
            Text("Tsy misy andininy tiana voatahiry", textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 4),
            Text("Tsindrio indroa mialoha ny andininy iray rehefa mamaky ianao mba hitahirizana azy eto.", textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _navigateToReader(VerseModel verse) {
    final bibleState = context.read<BibleCubit>().state;
    List<BookModel> books = bibleState is BibleBooksLoaded ? bibleState.books : (bibleState is BibleChapterLoaded ? bibleState.books : []);
    if (books.isNotEmpty) {
      try {
        final book = books.firstWhere((b) => b.number == verse.bookNumber);
        Navigator.push(context, NoAnimationPageRoute(builder: (_) => ReaderScreen(book: book, initialChapter: verse.chapter))).then((_) {
          if (!mounted) return;
          context.read<BookmarkCubit>().loadBookmarks();
        });
      } catch (_) {}
    }
  }
}
