import 'package:flutter/material.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/presentation/screens/hymn_reader_screen.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class HymnTile extends StatelessWidget {
  final HymnModel hymn;
  final bool isSearchResult;

  const HymnTile({
    super.key,
    required this.hymn,
    required this.isSearchResult,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String categoryBadge = "";
    if (isSearchResult) {
      if (hymn.category == 'ffpm') categoryBadge = "FFPM";
      if (hymn.category == 'fanampiny') categoryBadge = "Fanampiny";
      if (hymn.category == 'antema') categoryBadge = "Antema";
    }

    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          NoAnimationPageRoute(builder: (_) => HymnReaderScreen(hymn: hymn)),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                "${hymn.number}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hymn.title,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (categoryBadge.isNotEmpty) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  categoryBadge,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
