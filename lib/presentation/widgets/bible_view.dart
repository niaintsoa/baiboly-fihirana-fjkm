import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/history_cubit.dart';
import 'package:baiboly_apk/data/models/history_item.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/models/fandaharana_item.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/presentation/cubits/fandaharana_cubit.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/screens/history_screen.dart';
import 'package:baiboly_apk/presentation/screens/fandaharana_screen.dart';
import 'package:baiboly_apk/presentation/screens/hymn_reader_screen.dart';
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

                    // Testament Tabs (Custom Pill design)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => tabController.animateTo(0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: tabController.index == 0
                                        ? LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.primary.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: tabController.index == 0 ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: tabController.index == 0
                                        ? [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withOpacity(0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Testamenta Taloha",
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 12,
                                        fontWeight: tabController.index == 0 ? FontWeight.bold : FontWeight.w600,
                                        color: tabController.index == 0 ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => tabController.animateTo(1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: tabController.index == 1
                                        ? LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.primary.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: tabController.index == 1 ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: tabController.index == 1
                                        ? [
                                            BoxShadow(
                                              color: theme.colorScheme.primary.withOpacity(0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Testamenta Vaovao",
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 12,
                                        fontWeight: tabController.index == 1 ? FontWeight.bold : FontWeight.w600,
                                        color: tabController.index == 1 ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Books Grid (active tab)
                    BookGrid(books: currentBooks, onChapterSelected: onRefresh),

                    // History Section
                    _buildHistorySection(context, theme, allBooks),

                    // Fandaharana Section
                    _buildFandaharanaSection(context, theme, allBooks),

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
                InkWell(
                  onTap: () {
                    Navigator.push(context, NoAnimationPageRoute(builder: (_) => const HistoryScreen()));
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tantara",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ],
                    ),
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

  Widget _buildFandaharanaSection(BuildContext context, ThemeData theme, List<BookModel> allBooks) {
    return BlocBuilder<FandaharanaCubit, FandaharanaState>(
      builder: (context, state) {
        if (state is FandaharanaLoaded && state.items.isNotEmpty) {
          final items = state.items.take(3).toList();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(context, NoAnimationPageRoute(builder: (_) => const FandaharanaScreen()));
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Fandaharana",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...items.map((item) => _buildFandaharanaTile(context, theme, item, allBooks)),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFandaharanaTile(BuildContext context, ThemeData theme, FandaharanaItem item, List<BookModel> allBooks) {
    return InkWell(
      onTap: () {
        if (item.type == 'verse') {
          final dataMap = jsonDecode(item.data) as Map<String, dynamic>;
          final bookNumber = dataMap['book_number'] as int? ?? dataMap['bookNumber'] as int? ?? dataMap['book'] as int? ?? dataMap['book_id'] as int? ?? 0;
          final chapter = dataMap['chapter'] as int? ?? dataMap['chapter_number'] as int? ?? 0;
          final verse = dataMap['verse'] as int? ?? dataMap['verse_number'] as int?;
          final endVerse = dataMap['end_verse'] as int? ?? dataMap['endVerse'] as int? ?? dataMap['end_verse_number'] as int? ?? dataMap['endVerseNumber'] as int?;
          final book = allBooks.firstWhere(
            (b) => b.number == bookNumber,
            orElse: () => BookModel.empty(),
          );
          if (book.number > 0) {
            Navigator.push(
              context,
              NoAnimationPageRoute(
                builder: (_) => ReaderScreen(
                  book: book,
                  initialChapter: chapter > 0 ? chapter : 1,
                  initialVerse: verse != null && verse > 0 ? verse : null,
                  initialEndVerse: endVerse != null && endVerse > 0 ? endVerse : null,
                ),
              ),
            );
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.secondary.withOpacity(0.06),
              theme.colorScheme.secondary.withOpacity(0.01),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.secondary.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.type == 'verse' ? Icons.menu_book : Icons.music_note,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: theme.colorScheme.secondary.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                initialEndVerse: item.endVerse,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.06),
              theme.colorScheme.primary.withOpacity(0.01),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.bookName} ${item.chapter}:${item.verse}${item.endVerse != null && item.endVerse != item.verse ? "-${item.endVerse}" : ""}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.delete_outline, size: 16, color: theme.colorScheme.error.withOpacity(0.6)),
                          onPressed: () {
                            context.read<HistoryCubit>().deleteItem(item);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.85),
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -20,
                  child: Icon(
                    Icons.format_quote,
                    size: 80,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "TENIN'ANDRIAMANITRA",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${selectedVerse['text']}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedVerse['ref'] ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
