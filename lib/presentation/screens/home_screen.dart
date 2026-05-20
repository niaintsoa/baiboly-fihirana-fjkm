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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Baiboly Malagasy",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Bouton Favoris compact
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                                );
                              },
                              icon: const Icon(Icons.bookmark_outline, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Barre de recherche compacte
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  "Hikaroka andininy...",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Verset du jour minimaliste
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
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
                                '"${_selectedVerse['text']}"',
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
                                  _selectedVerse['ref']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Section Dernier livre lu compacte
                        if (_lastReadBook != null) ...[
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
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.menu_book, color: theme.colorScheme.secondary, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Tohizo: ${_lastReadBook!.name} Toko $_lastReadChapter",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 10, color: theme.colorScheme.secondary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        
                        // Onglets Testamenta minimaux
                        TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                          labelStyle: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: const [
                            Tab(height: 30, text: "Testamenta Taloha"),
                            Tab(height: 30, text: "Testamenta Vaovao"),
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
          padding: EdgeInsets.all(12.0),
          child: Text("Tsy misy boky hita", style: TextStyle(fontSize: 11)),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () => _showChapterSelectionDialog(book),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${book.totalChapters} toko",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Boîte de dialogue compacte pour choisir le chapitre
  void _showChapterSelectionDialog(BookModel book) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.7,
          minChildSize: 0.2,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Toko - ${book.name}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: book.totalChapters,
                    itemBuilder: (context, index) {
                      final chapter = index + 1;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
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
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.08),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "$chapter",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 13,
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
