import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/presentation/cubits/fandaharana_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/screens/hymn_reader_screen.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class FandaharanaScreen extends StatelessWidget {
  const FandaharanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Fandaharana",
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Fafana ny fandaharana rehetra?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tsia"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<FandaharanaCubit>().clearItems();
                        Navigator.pop(context);
                      },
                      child: const Text("Eny"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FandaharanaCubit, FandaharanaState>(
        builder: (context, state) {
          if (state is FandaharanaLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  "Tsy mbola misy fandaharana",
                  style: TextStyle(fontSize: 12),
                ),
              );
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) {
                // To be implemented fully later if needed. For now just view.
              },
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => context.read<FandaharanaCubit>().removeItem(item.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    key: ValueKey('card_${item.id}'),
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Icon(
                        item.type == 'verse' ? Icons.menu_book : Icons.music_note,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                      onTap: () {
                        if (item.type == 'verse') {
                          final verseMap = jsonDecode(item.data);
                          final verse = VerseModel.fromMap(verseMap);
                          final bibleState = context.read<BibleCubit>().state;
                          if (bibleState is BibleBooksLoaded) {
                            final book = bibleState.books.firstWhere(
                              (b) => b.number == verse.bookNumber,
                              orElse: () => BookModel.empty(),
                            );
                            if (book.number > 0) {
                              Navigator.push(
                                context,
                                NoAnimationPageRoute(
                                  builder: (_) => ReaderScreen(
                                    book: book,
                                    initialChapter: verse.chapter,
                                    initialVerse: verse.verse > 0 ? verse.verse : null,
                                  ),
                                ),
                              );
                            }
                          }
                        } else if (item.type == 'hymn') {
                          final hymnMap = jsonDecode(item.data);
                          final hymn = HymnModel.fromMap(hymnMap);
                          Navigator.push(
                            context,
                            NoAnimationPageRoute(
                              builder: (_) => HymnReaderScreen(hymn: hymn),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
