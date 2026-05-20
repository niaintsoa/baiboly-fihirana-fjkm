import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
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

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BibleHomeHeader(selectedVerse: selectedVerse, onRefresh: onRefresh),
              ),
              SliverToBoxAdapter(
                child: Container(
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
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    BookGrid(books: otBooks, onChapterSelected: onRefresh),
                    BookGrid(books: ntBooks, onChapterSelected: onRefresh),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
