import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';
import 'package:baiboly_apk/presentation/cubits/bible_cubit.dart';
import 'package:baiboly_apk/presentation/screens/fihirana_screen.dart';
import 'package:baiboly_apk/presentation/widgets/bible_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  Map<String, String> _selectedVerse = {
    "text": "Fa toy izao no nitiavan'Andriamanitra izao tontolo izao: nomeny ny Zanany Lahitokana...",
    "ref": "Jaona 3:16"
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRandomVerse();
    context.read<BibleCubit>().loadBooks();
  }

  Future<void> _loadRandomVerse() async {
    try {
      final repo = context.read<BibleRepository>();
      final verse = await repo.getRandomVerse();
      if (verse != null && mounted) {
        setState(() {
          _selectedVerse = {
            "text": verse.text,
            "ref": "${verse.bookName} ${verse.chapter}:${verse.verse}"
          };
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _currentIndex == 0
          ? SafeArea(
              child: BibleView(
                tabController: _tabController,
                selectedVerse: _selectedVerse,
                onRefresh: () => setState(() {}),
              ),
            )
          : const FihiranaScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06), width: 0.5))),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 18,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Baiboly"),
            BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Fihirana"),
          ],
        ),
      ),
    );
  }
}
