import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/cubits/search_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';

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
    // Demander le focus sur le clavier au démarrage pour plus de fluidité
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: "Hikaroka ao amin'ny Baiboly...",
            border: InputBorder.none,
          ),
          onChanged: (query) {
            context.read<SearchCubit>().search(query);
          },
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
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
          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
 
          if (state is SearchSuccess) {
            final results = state.results;
            if (results.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 36, color: theme.colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        "Tsy nisy andininy mifanaraka amin'ny '${state.query}'",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }
 
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final verse = results[index];
                return _buildSearchResultTile(verse, state.query);
              },
            );
          }
 
          if (state is SearchError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            );
          }
 
          // SearchInitial
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 40,
                    color: theme.colorScheme.primary.withOpacity(0.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Soraty eo ambony ny teny tadiavinao",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ohatra: 'Fitiavana', 'Fahavelomana'",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget affichant un résultat de recherche avec le texte en surbrillance
  Widget _buildSearchResultTile(VerseModel verse, String query) {
    final theme = Theme.of(context);
    
    // Extraire et surligner le mot recherché
    final text = verse.text;
    final List<TextSpan> spans = [];
    
    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();
    
    int start = 0;
    int indexOfQuery = lowercaseText.indexOf(lowercaseQuery);
    
    if (indexOfQuery != -1) {
      while (indexOfQuery != -1) {
        // Ajouter le texte avant la correspondance
        if (indexOfQuery > start) {
          spans.add(TextSpan(text: text.substring(start, indexOfQuery)));
        }
        
        // Ajouter la correspondance en gras/surligné
        spans.add(TextSpan(
          text: text.substring(indexOfQuery, indexOfQuery + query.length),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          ),
        ));
        
        start = indexOfQuery + query.length;
        indexOfQuery = lowercaseText.indexOf(lowercaseQuery, start);
      }
      
      // Ajouter le reste du texte
      if (start < text.length) {
        spans.add(TextSpan(text: text.substring(start)));
      }
    } else {
      spans.add(TextSpan(text: text));
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.06)),
      ),
      color: theme.colorScheme.primaryContainer.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _navigateToReader(verse),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${verse.bookName} ${verse.chapter}:${verse.verse}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(children: spans),
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
    );
  }

  // Rediriger l'utilisateur vers l'écran de lecture sur le bon chapitre
  void _navigateToReader(VerseModel verse) {
    // Il faut retrouver l'objet BookModel correspondant pour charger le lecteur
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
        );
      } catch (_) {
        // En cas d'erreur de correspondance
      }
    }
  }
}
