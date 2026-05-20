import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/bookmark_model.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';

class BookmarkTile extends StatelessWidget {
  final BookmarkModel bookmark;
  final VoidCallback onTap;

  const BookmarkTile({
    super.key,
    required this.bookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verse = VerseModel(
      id: bookmark.id,
      bookNumber: bookmark.bookNumber,
      bookName: bookmark.bookName,
      chapter: bookmark.chapter,
      verse: bookmark.verse,
      text: bookmark.text,
    );

    return Dismissible(
      key: Key('bookmark_${bookmark.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red.shade800,
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      onDismissed: (_) {
        final cubit = context.read<BookmarkCubit>();
        final messenger = ScaffoldMessenger.of(context);
        cubit.toggleBookmark(verse);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "Voaesorina: ${bookmark.bookName} ${bookmark.chapter}:${bookmark.verse}",
              style: const TextStyle(fontSize: 11),
            ),
            action: SnackBarAction(
              label: "Haverina",
              onPressed: () {
                cubit.toggleBookmark(verse);
                messenger.clearSnackBars();
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.06)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${bookmark.bookName} ${bookmark.chapter}:${bookmark.verse}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade800),
                      onPressed: () {
                        final cubit = context.read<BookmarkCubit>();
                        final messenger = ScaffoldMessenger.of(context);
                        cubit.toggleBookmark(verse);
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              "Noesorina: ${bookmark.bookName} ${bookmark.chapter}:${bookmark.verse}",
                              style: const TextStyle(fontSize: 11),
                            ),
                            action: SnackBarAction(
                              label: "Haverina",
                              onPressed: () {
                                cubit.toggleBookmark(verse);
                                messenger.clearSnackBars();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  bookmark.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.3,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
