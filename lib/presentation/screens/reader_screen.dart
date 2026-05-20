import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';
import 'package:baiboly_apk/presentation/cubits/bookmark_cubit.dart';

class ReaderScreen extends StatefulWidget {
  final BookModel book;
  final int initialChapter;

  const ReaderScreen({
    super.key,
    required this.book,
    required this.initialChapter,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PageController _pageController;
  late int _currentChapter;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _pageController = PageController(initialPage: _currentChapter - 1);
    
    // Charger le chapitre initial
    _loadChapterData(_currentChapter);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadChapterData(int chapter) {
    context.read<BibleCubit>().loadChapter(widget.book, chapter);
    _saveLastRead(chapter);
  }

  Future<void> _saveLastRead(int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_book_number', widget.book.number);
    await prefs.setInt('last_read_chapter', chapter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<BibleCubit, BibleState>(
          builder: (context, state) {
            String title = widget.book.name;
            if (state is BibleChapterLoaded) {
              title = "${state.currentBook.name} $_currentChapter";
            }
            return Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
            );
          },
        ),
        actions: [
          // Bouton Réglages Lecture (Taille du texte et Thème)
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showSettingsBottomSheet(),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.book.totalChapters,
        onPageChanged: (pageIndex) {
          final newChapter = pageIndex + 1;
          setState(() {
            _currentChapter = newChapter;
          });
          _loadChapterData(newChapter);
        },
        itemBuilder: (context, index) {
          final chapterIndex = index + 1;
          return BlocBuilder<BibleCubit, BibleState>(
            builder: (context, state) {
              if (state is BibleLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is BibleChapterLoaded && state.currentChapter == chapterIndex) {
                return _buildVersesList(state.verses);
              }

              if (state is BibleError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Affiche la liste des versets d'un chapitre
  Widget _buildVersesList(List<VerseModel> verses) {
    final theme = Theme.of(context);
    
    if (verses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Tsy misy andininy ato amin'ity toko ity.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, prefs) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80), // Marge en bas pour le scroll
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onLongPress: () => _showVerseActions(verse),
                onDoubleTap: () {
                  context.read<BookmarkCubit>().toggleBookmark(verse);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Voaova ny andininy tianao (${verse.bookName} ${verse.chapter}:${verse.verse})",
                        style: const TextStyle(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        // Numéro du verset
                        TextSpan(
                          text: "${verse.verse} ",
                          style: TextStyle(
                            fontSize: prefs.fontSize - 4,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontFeatures: const [FontFeature.superscripts()],
                          ),
                        ),
                        // Contenu du verset
                        TextSpan(
                          text: verse.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: prefs.fontSize,
                            height: prefs.lineSpacing,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Barre inférieure pour naviguer rapidement (Chapitre précédent / suivant)
  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chapitre précédent
          IconButton.outlined(
            onPressed: _currentChapter > 1
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          
          Text(
            "Toko $_currentChapter / ${widget.book.totalChapters}",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // Chapitre suivant
          IconButton.outlined(
            onPressed: _currentChapter < widget.book.totalChapters
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  // Boîte de dialogue pour les réglages de lecture
  void _showSettingsBottomSheet() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return BlocBuilder<PreferencesCubit, PreferencesState>(
          builder: (context, prefs) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fikirana ny famakiana",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Réglage Taille de police
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Haben'ny soratra",
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                      ),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: prefs.fontSize > 14
                                ? () => context.read<PreferencesCubit>().decreaseFontSize()
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "${prefs.fontSize.toInt()}",
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: prefs.fontSize < 32
                                ? () => context.read<PreferencesCubit>().increaseFontSize()
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Choix de Thèmes
                  Text(
                    "Loko ambadika",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeOption(context, 'light', 'Mamazava', const Color(0xFFFDFBF7), const Color(0xFF2C2520), prefs.themeMode),
                      _buildThemeOption(context, 'sepia', 'Sepia', const Color(0xFFF4ECD8), const Color(0xFF3E2723), prefs.themeMode),
                      _buildThemeOption(context, 'dark', 'Maizina', const Color(0xFF141416), const Color(0xFFE3E3E6), prefs.themeMode),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String themeValue,
    String label,
    Color bg,
    Color text,
    String currentTheme,
  ) {
    final isSelected = currentTheme == themeValue;
    final themeCubit = context.read<PreferencesCubit>();

    return InkWell(
      onTap: () => themeCubit.setThemeMode(themeValue),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Aa",
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: text.withOpacity(0.8),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BottomSheet d'actions sur un verset spécifique (Favori, Copie, Partage)
  void _showVerseActions(VerseModel verse) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<bool>(
          future: context.read<BookmarkCubit>().checkIsBookmarked(verse),
          builder: (context, snapshot) {
            final isBookmarked = snapshot.data ?? false;
            
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${verse.bookName} ${verse.chapter}:${verse.verse}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verse.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  
                  // Ligne d'actions
                  ListTile(
                    leading: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(isBookmarked ? "Esory amin'ny tiana" : "Ampidiro amin'ny tiana"),
                    onTap: () {
                      context.read<BookmarkCubit>().toggleBookmark(verse);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked ? "Voaesorina amin'ny andininy tianao" : "Tafiditra amin'ny andininy tianao",
                          ),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text("Kopia ny andininy"),
                    onTap: () {
                      Clipboard.setData(ClipboardData(
                        text: "${verse.text} (${verse.bookName} ${verse.chapter}:${verse.verse})",
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nadika tao amin'ny clipboard")),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text("Zaraina"),
                    onTap: () {
                      // Simuler le partage de l'application
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Zaraina: ${verse.bookName} ${verse.chapter}:${verse.verse}",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
