import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/presentation/widgets/verse_tile.dart';

class VerseListView extends StatefulWidget {
  final List<VerseModel> verses;
  final int? initialVerse;

  const VerseListView({super.key, required this.verses, this.initialVerse});

  @override
  State<VerseListView> createState() => _VerseListViewState();
}

class _VerseListViewState extends State<VerseListView> {
  final Map<int, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse();
      });
    }
  }

  void _scrollToVerse() {
    final key = _keys[widget.initialVerse];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.verses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("Tsy misy andininy ato amin'ity toko ity.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 50),
      itemCount: widget.verses.length,
      itemBuilder: (context, index) {
        final verse = widget.verses[index];
        final key = _keys.putIfAbsent(verse.verse, () => GlobalKey());
        return VerseTile(
          key: key,
          verse: verse,
          baseFontSize: 15.0,
        );
      },
    );
  }
}
