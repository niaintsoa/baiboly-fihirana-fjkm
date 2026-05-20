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
        titleSpacing: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<BibleCubit, BibleState>(
          builder: (context, state) {
            String title = widget.book.name;
            if (state is BibleChapterLoaded) {
              title = "${state.currentBook.name} $_currentChapter";
            }
            return Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, size: 20),
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
                return Center(child: Text(state.message, style: const TextStyle(fontSize: 12)));
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Affiche la liste des versets d'un chapitre (compact)
  Widget _buildVersesList(List<VerseModel> verses) {
    final theme = Theme.of(context);
    
    if (verses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Tsy misy andininy ato amin'ity toko ity.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, prefs) {
        // Forcer une taille de police plus petite que par défaut
        final double baseFontSize = prefs.fontSize > 18 ? 15.0 : prefs.fontSize - 2.0;

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 50),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: InkWell(
                onLongPress: () => _showVerseActions(verse),
                onDoubleTap: () {
                  context.read<BookmarkCubit>().toggleBookmark(verse);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Voaova ny andininy tianao (${verse.bookName} ${verse.chapter}:${verse.verse})",
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${verse.verse} ",
                          style: TextStyle(
                            fontSize: baseFontSize - 3,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        TextSpan(
                          text: verse.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: baseFontSize,
                            height: 1.3,
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

  // Barre inférieure pour naviguer rapidement (Chapitre précédent / suivant) - compacte
  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentChapter > 1
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
          
          Text(
            "Toko $_currentChapter / ${widget.book.totalChapters}",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),

          IconButton(
            onPressed: _currentChapter < widget.book.totalChapters
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.arrow_forward, size: 20),
          ),
        ],
      ),
    );
  }

  // Boîte de dialogue compacte pour les réglages de lecture
  void _showSettingsBottomSheet() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return BlocBuilder<PreferencesCubit, PreferencesState>(
          builder: (context, prefs) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fikirana ny famakiana",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Haben'ny soratra",
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                      Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed: prefs.fontSize > 12
                                ? () => context.read<PreferencesCubit>().decreaseFontSize()
                                : null,
                            icon: const Icon(Icons.remove, size: 18),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              "${prefs.fontSize.toInt()}",
                              style: theme.textTheme.titleMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed: prefs.fontSize < 24
                                ? () => context.read<PreferencesCubit>().increaseFontSize()
                                : null,
                            icon: const Icon(Icons.add, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Loko ambadika",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeOption(context, 'light', 'Mamazava', const Color(0xFFFDFBF7), const Color(0xFF2C2520), prefs.themeMode),
                      _buildThemeOption(context, 'sepia', 'Sepia', const Color(0xFFF4ECD8), const Color(0xFF3E2723), prefs.themeMode),
                      _buildThemeOption(context, 'dark', 'Maizina', const Color(0xFF141416), const Color(0xFFE3E3E6), prefs.themeMode),
                    ],
                  ),
                  const SizedBox(height: 8),
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Aa",
              style: TextStyle(
                color: text,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: text.withOpacity(0.8),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BottomSheet d'actions sur un verset spécifique (Favori, Copie, Partage) - compacte
  void _showVerseActions(VerseModel verse) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return FutureBuilder<bool>(
          future: context.read<BookmarkCubit>().checkIsBookmarked(verse),
          builder: (context, snapshot) {
            final isBookmarked = snapshot.data ?? false;
            
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${verse.bookName} ${verse.chapter}:${verse.verse}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    verse.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    title: Text(
                      isBookmarked ? "Esory amin'ny tiana" : "Ampidiro amin'ny tiana",
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      context.read<BookmarkCubit>().toggleBookmark(verse);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked ? "Voaesorina amin'ny andininy tianao" : "Tafiditra amin'ny andininy tianao",
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.copy, size: 18),
                    title: const Text(
                      "Kopia ny andininy",
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Clipboard.setData(ClipboardData(
                        text: "${verse.text} (${verse.bookName} ${verse.chapter}:${verse.verse})",
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Nadika tao amin'ny clipboard",
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.share, size: 18),
                    title: const Text(
                      "Zaraina",
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Zaraina: ${verse.bookName} ${verse.chapter}:${verse.verse}",
                            style: const TextStyle(fontSize: 11),
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
