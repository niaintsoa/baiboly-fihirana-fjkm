import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/cubits/search_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/widgets/search_result_tile.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => Navigator.pop(context)),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: const InputDecoration(hintText: "Hikaroka ao amin'ny Baiboly...", border: InputBorder.none),
          onChanged: (q) => context.read<SearchCubit>().search(q),
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.normal),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _searchController.clear();
                context.read<SearchCubit>().clearSearch();
              },
            ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) return const Center(child: CircularProgressIndicator());
          if (state is SearchSuccess) {
            final results = state.results;
            if (results.isEmpty) return _buildEmptyResults(theme, state.query);
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final verse = results[index];
                return SearchResultTile(verse: verse, query: state.query, onTap: () => _navigateToReader(verse));
              },
            );
          }
          if (state is SearchError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 12)));
          return _buildInitialPrompt(theme);
        },
      ),
    );
  }

  Widget _buildEmptyResults(ThemeData theme, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 36, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text("Tsy nisy andininy mifanaraka amin'ny '$query'", textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialPrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 40, color: theme.colorScheme.primary.withOpacity(0.15)),
            const SizedBox(height: 8),
            Text("Soraty eo ambony ny teny tadiavinao", textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 4),
            Text("Ohatra: 'Fitiavana', 'Fahavelomana'", textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _navigateToReader(VerseModel verse) {
    final bibleState = context.read<BibleCubit>().state;
    List<BookModel> books = bibleState is BibleBooksLoaded ? bibleState.books : [];
    if (books.isNotEmpty) {
      try {
        final book = books.firstWhere((b) => b.number == verse.bookNumber);
        Navigator.push(
          context,
          NoAnimationPageRoute(
            builder: (_) => ReaderScreen(
              book: book,
              initialChapter: verse.chapter,
              initialVerse: verse.verse,
            ),
          ),
        );
      } catch (_) {}
    }
  }
}
