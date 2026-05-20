import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';

class SearchResultTile extends StatelessWidget {
  final VerseModel verse;
  final String query;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.verse,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = verse.text;
    final List<TextSpan> spans = [];

    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();

    int start = 0;
    int indexOfQuery = lowercaseText.indexOf(lowercaseQuery);

    if (indexOfQuery != -1) {
      while (indexOfQuery != -1) {
        if (indexOfQuery > start) {
          spans.add(TextSpan(text: text.substring(start, indexOfQuery)));
        }
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
        onTap: onTap,
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
                  Icon(Icons.arrow_forward_ios, size: 10, color: theme.colorScheme.primary.withOpacity(0.5)),
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
}
