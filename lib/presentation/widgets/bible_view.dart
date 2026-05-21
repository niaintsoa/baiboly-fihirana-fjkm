import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/history_cubit.dart';
import 'package:baiboly_apk/data/models/history_item.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';
import 'package:baiboly_apk/presentation/widgets/book_grid.dart';
import 'package:baiboly_apk/presentation/widgets/bible_home_header.dart';

class BibleView extends StatelessWidget {
  final TabController tabController;
  final Map<String, String> selectedVerse;
  final VoidCallback onRefresh;

  const BibleView({
    super.key,
    required this.tabController,
    required this.selectedVerse,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<BibleCubit, BibleState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is BibleLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BibleBooksLoaded) {
          final allBooks = state.books;
          final otBooks = allBooks.where((b) => !b.isNewTestament).toList();
          final ntBooks = allBooks.where((b) => b.isNewTestament).toList();

          return AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              final currentBooks = tabController.index == 0 ? otBooks : ntBooks;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (title, search bar, NO Word of God here)
                    BibleHomeHeader(
                      selectedVerse: selectedVerse,
                      onRefresh: onRefresh,
                      showWordOfGod: false,
                    ),

                    // Testament Tabs
                    Container(
                      color: theme.colorScheme.surface,
                      child: TabBar(
                        controller: tabController,
                        isScrollable: false,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: theme.colorScheme.primary,
                        indicatorWeight: 1.5,
                        labelStyle: theme.textTheme.titleMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(height: 30, text: "Testamenta Taloha"),
                          Tab(height: 30, text: "Testamenta Vaovao"),
                        ],
                      ),
                    ),

                    // Books Grid (active tab)
                    BookGrid(books: currentBooks, onChapterSelected: onRefresh),

                    // History Section
                    _buildHistorySection(context, theme, allBooks),

                    // Word of God (Tenin'Andriamanitra) at the bottom
                    _buildWordOfGodCard(context, theme),

                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHistorySection(BuildContext context, ThemeData theme, List<BookModel> allBooks) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoaded && state.history.isNotEmpty) {
          final items = state.history.take(5).toList();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Tantara",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ...items.map((item) => _buildHistoryTile(context, theme, item, allBooks)),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHistoryTile(BuildContext context, ThemeData theme, HistoryItem item, List<BookModel> allBooks) {
    return InkWell(
      onTap: () {
        final book = allBooks.firstWhere(
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
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 14, color: theme.colorScheme.primary.withOpacity(0.7)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.bookName} ${item.chapter}:${item.verse}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.close, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              onPressed: () {
                context.read<HistoryCubit>().deleteItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordOfGodCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the verse if bookNumber, chapter, verse are available
          final bookNumberStr = selectedVerse['bookNumber'];
          final chapterStr = selectedVerse['chapter'];
          final verseStr = selectedVerse['verse'];
          if (bookNumberStr != null && chapterStr != null && verseStr != null) {
            final bibleState = context.read<BibleCubit>().state;
            if (bibleState is BibleBooksLoaded) {
              final bookNumber = int.tryParse(bookNumberStr);
              final chapter = int.tryParse(chapterStr);
              final verse = int.tryParse(verseStr);
              if (bookNumber != null && chapter != null && verse != null) {
                final book = bibleState.books.firstWhere(
                  (b) => b.number == bookNumber,
                  orElse: () => BookModel.empty(),
                );
                if (book.number > 0) {
                  Navigator.push(
                    context,
                    NoAnimationPageRoute(
                      builder: (_) => ReaderScreen(
                        book: book,
                        initialChapter: chapter,
                        initialVerse: verse,
                      ),
                    ),
                  );
                }
              }
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tenin'Andriamanitra:",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"${selectedVerse['text']}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  selectedVerse['ref'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
