import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/hymn_verse_model.dart';

class HymnVerseTile extends StatelessWidget {
  final HymnVerseModel verse;
  final double baseFontSize;

  const HymnVerseTile({
    super.key,
    required this.verse,
    required this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isChorus = verse.isChorus;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: isChorus ? const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0) : EdgeInsets.zero,
      decoration: isChorus
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  width: 3,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isChorus)
            Text(
              "Fiverenany :",
              style: TextStyle(
                fontSize: baseFontSize - 2,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (verse.verseNumber > 0)
            Text(
              "${verse.verseNumber}.",
              style: TextStyle(
                fontSize: baseFontSize - 2,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            verse.lyrics,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: baseFontSize,
              height: 1.4,
              fontStyle: isChorus ? FontStyle.italic : null,
            ),
          ),
        ],
      ),
    );
  }
}
