import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/screens/reader_screen.dart';
import 'package:baiboly_apk/presentation/screens/search_screen.dart';
import 'package:baiboly_apk/presentation/screens/bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BookModel? _lastReadBook;
  int _lastReadChapter = 1;

  // Verset du jour (Démonstration élégante)
  final List<Map<String, String>> _versesOfTheDay = [
    {
      "text": "Fa fantatro ny hevitra eritreretiko ny aminareo, dia hevitra hahasoa, fa tsy hahantrana, mba hanome anareo farany misy fanantenana.",
      "ref": "Jeremia 29:11"
    },
    {
      "text": "Ny Tompo no Mpiandry ahy, tsy hanan-java-mahory aho.",
      "ref": "Salamo 23:1"
    },
    {
      "text": "Fa toy izao no nitiavan'Andriamanitra izao tontolo izao: nomeny ny Zanany Lahitokana, mba tsy ho very izay rehetra mino Azy, fa hanana fiainana mandrakizay.",
      "ref": "Jaona 3:16"
    },
    {
      "text": "Ampianaro anay ny fanisana ny andronay, mba hahazoanay fo hendry.",
      "ref": "Salamo 90:12"
    }
  ];
  late Map<String, String> _selectedVerse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Choix aléatoire du verset du jour
    final random = Random();
    _selectedVerse = _versesOfTheDay[random.nextInt(_versesOfTheDay.length)];
    _loadLastRead();
    
    // Charger les livres de la Bible
    context.read<BibleCubit>().loadBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    
    final bookNum = prefs.getInt('last_read_book_number');
    final chapter = prefs.getInt('last_read_chapter') ?? 1;

    if (bookNum != null) {
      // Rechercher le livre correspondant dès que les livres sont chargés
      final state = context.read<BibleCubit>().state;
      if (state is BibleBooksLoaded) {
        _setLastReadFromList(state.books, bookNum, chapter);
      }
    }
  }

  void _setLastReadFromList(List<BookModel> books, int bookNum, int chapter) {
    try {
      final book = books.firstWhere((b) => b.number == bookNum);
      setState(() {
        _lastReadBook = book;
        _lastReadChapter = chapter;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<BibleCubit, BibleState>(
          listener: (context, state) {
            if (state is BibleBooksLoaded && _lastReadBook == null) {
              // Réessayer de charger le dernier livre lu une fois les livres chargés
              SharedPreferences.getInstance().then((prefs) {
                final bookNum = prefs.getInt('last_read_book_number');
                final chapter = prefs.getInt('last_read_chapter') ?? 1;
                if (bookNum != null) {
                  _setLastReadFromList(state.books, bookNum, chapter);
                }
              });
            }
          },
          builder: (context, state) {
            if (state is BibleLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List<BookModel> allBooks = [];
            if (state is BibleBooksLoaded) {
              allBooks = state.books;
            } else if (state is BibleChapterLoaded) {
              allBooks = state.books;
            } else if (state is BibleError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<BibleCubit>().loadBooks(),
                        child: const Text("Hanandrana indray"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final otBooks = allBooks.where((b) => !b.isNewTestament).toList();
            final ntBooks = allBooks.where((b) => b.isNewTestament).toList();

            return CustomScrollView(
              slivers: [
                // En-tête personnalisé fluide
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tonga soa",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Baiboly Malagasy",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Bouton Favoris
                            IconButton.filledTonal(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                                );
                              },
                              icon: const Icon(Icons.bookmark_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Barre de recherche stylisée (Bouton qui ouvre l'écran de recherche)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(
                                  "Hikaroka andininy...",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Verset du jour (Design premium avec dégradé et micro-ombras)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withBlue(100).withRed(120),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: Colors.white70, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Tenin'Andriamanitra ho anao",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '"${_selectedVerse['text']}"',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  _selectedVerse['ref']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section Dernier livre lu (si existant)
                        if (_lastReadBook != null) ...[
                          Text(
                            "Tohizo ny famakiana",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReaderScreen(
                                    book: _lastReadBook!,
                                    initialChapter: _lastReadChapter,
                                  ),
                                ),
                              ).then((_) => _loadLastRead());
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withOpacity(0.15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book, color: theme.colorScheme.secondary, size: 28),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${_lastReadBook!.name} (Toko $_lastReadChapter)",
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Kitiho raha hanohy ny famakiana",
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.secondary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Titre des Livres
                        Text(
                          "Boky ao amin'ny Baiboly",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Onglets Testament Taloha / Vaovao
                        TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                          labelStyle: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: const [
                            Tab(text: "Testamenta Taloha"),
                            Tab(text: "Testamenta Vaovao"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid des Livres
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookGrid(otBooks),
                      _buildBookGrid(ntBooks),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookGrid(List<BookModel> books) {
    final theme = Theme.of(context);
    
    if (books.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Tsy misy boky hita"),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20.0),
      physics: const ClampingScrollPhysics(), // pour éviter les conflits de scroll
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () => _showChapterSelectionDialog(book),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                // Raccourci ou numéro du livre discret
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${book.totalChapters} toko",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Boîte de dialogue premium pour choisir le chapitre
  void _showChapterSelectionDialog(BookModel book) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Mifidiana Toko - ${book.name}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: book.totalChapters,
                    itemBuilder: (context, index) {
                      final chapter = index + 1;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context); // fermer le BottomSheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderScreen(
                                book: book,
                                initialChapter: chapter,
                              ),
                            ),
                          ).then((_) => _loadLastRead());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "$chapter",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
