import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/presentation/widgets/verse_tile.dart';

class VerseListView extends StatefulWidget {
  final List<VerseModel> verses;
  final int? initialVerse, initialEndVerse;
  const VerseListView({super.key, required this.verses, this.initialVerse, this.initialEndVerse});
  @override
  State<VerseListView> createState() => _VerseListViewState();
}

class _VerseListViewState extends State<VerseListView> {
  final Map<int, GlobalKey> _keys = {};
  int? _hiStart, _hiEnd;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _hiStart = widget.initialVerse;
    _hiEnd = widget.initialEndVerse;
    _scrollController = ScrollController();
    if (widget.initialVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToVerse());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToVerse() {
    if (!_scrollController.hasClients || widget.initialVerse == null) return;
    final estimate = (widget.initialVerse! - 1) * 65.0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(estimate.clamp(0.0, maxScroll));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _keys[widget.initialVerse];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 1),
          curve: Curves.linear,
        );
      }
    });
  }

  bool _shouldHighlight(int num) {
    if (_hiStart == null) return false;
    return _hiEnd == null ? num == _hiStart : (num >= _hiStart! && num <= _hiEnd!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.verses.isEmpty) {
      return const Center(child: Text("Tsy misy andininy.", style: TextStyle(fontSize: 12)));
    }
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thickness: WidgetStateProperty.resolveWith<double?>((states) {
          if (states.contains(WidgetState.dragged) || states.contains(WidgetState.hovered)) {
            return 12.0;
          }
          return 5.0;
        }),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        interactive: true,
        radius: const Radius.circular(5),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 50),
          itemCount: widget.verses.length,
          itemBuilder: (context, index) {
            final verse = widget.verses[index];
            final key = _keys.putIfAbsent(verse.verse, () => GlobalKey());
            return VerseTile(
              key: key,
              verse: verse,
              baseFontSize: 15.0,
              isHighlighted: _shouldHighlight(verse.verse),
            );
          },
        ),
      ),
    );
  }
}
