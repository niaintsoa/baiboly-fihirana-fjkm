import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/cubits/history_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
          "Tantara",
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Fafana ny tantara rehetra?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tsia"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<HistoryCubit>().clearHistory();
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
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoaded) {
            final items = state.history;
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  "Tsy misy tantara",
                  style: TextStyle(fontSize: 12),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.bookName + item.chapter.toString() + item.verse.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => context.read<HistoryCubit>().deleteItem(item),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    key: ValueKey('history_${item.bookName}_${item.chapter}_${item.verse}'),
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
                        Icons.access_time,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        '${item.bookName} ${item.chapter}:${item.verse}${item.endVerse != null && item.endVerse != item.verse ? "-${item.endVerse}" : ""}',
                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                      onTap: () {
                        final bibleState = context.read<BibleCubit>().state;
                        if (bibleState is BibleBooksLoaded) {
                          final book = bibleState.books.firstWhere(
                            (b) => b.number == item.bookNumber,
                            orElse: () => BookModel.empty(),
                          );
                          if (book.number > 0) {
                            Navigator.push(
                              context,
                              NoAnimationPageRoute(
                                builder: (_) => ReaderScreen(
                                  book: book,
                                  initialChapter: item.chapter,
                                  initialVerse: item.verse,
                                  initialEndVerse: item.endVerse,
                                ),
                              ),
                            );
                          }
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
