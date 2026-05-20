import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les favoris au démarrage de l'écran
    context.read<BookmarkCubit>().loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Andininy Tianao"),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarkLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BookmarkLoaded) {
            final bookmarks = state.bookmarks;
            if (bookmarks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Tsy misy andininy tiana voatahiry",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tsindrio indroa mialoha ny andininy iray rehefa mamaky ianao mba hitahirizana azy eto.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                
                // Conversion en VerseModel pour pouvoir manipuler les fonctions existantes
                final verse = VerseModel(
                  id: bookmark.id,
                  bookNumber: bookmark.bookNumber,
                  bookName: bookmark.bookName,
                  chapter: bookmark.chapter,
                  verse: bookmark.verse,
                  text: bookmark.text,
                );

                // Swipe-to-dismiss premium pour supprimer des favoris
                return Dismissible(
                  key: Key('bookmark_${bookmark.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red.shade800,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    context.read<BookmarkCubit>().toggleBookmark(verse);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Voaesorina: ${bookmark.bookName} ${bookmark.chapter}:${bookmark.verse}"),
                        action: SnackBarAction(
                          label: "Haverina",
                          onPressed: () {
                            context.read<BookmarkCubit>().toggleBookmark(verse);
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.08)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _navigateToReader(verse),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${bookmark.bookName} ${bookmark.chapter}:${bookmark.verse}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bookmark.text,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                height: 1.4,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (state is BookmarkError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToReader(VerseModel verse) {
    final bibleState = context.read<BibleCubit>().state;
    List<BookModel> books = [];
    if (bibleState is BibleBooksLoaded) {
      books = bibleState.books;
    } else if (bibleState is BibleChapterLoaded) {
      books = bibleState.books;
    }

    if (books.isNotEmpty) {
      try {
        final book = books.firstWhere((b) => b.number == verse.bookNumber);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReaderScreen(
              book: book,
              initialChapter: verse.chapter,
            ),
          ),
        ).then((_) {
          if (!mounted) return;
          // Recharger les favoris au retour si des modifications ont eu lieu
          context.read<BookmarkCubit>().loadBookmarks();
        });
      } catch (_) {}
    }
  }
}
