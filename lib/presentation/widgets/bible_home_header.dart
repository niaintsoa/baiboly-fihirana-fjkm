import 'package:flutter/material.dart';
import 'package:baiboly_apk/presentation/screens/bookmarks_screen.dart';
import 'package:baiboly_apk/presentation/screens/search_screen.dart';
import 'package:baiboly_apk/presentation/widgets/theme_settings_sheet.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class BibleHomeHeader extends StatelessWidget {
  final Map<String, String> selectedVerse;
  final VoidCallback onRefresh;

  const BibleHomeHeader({
    super.key,
    required this.selectedVerse,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Baiboly Malagasy",
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 12),
                    onPressed: () => _showThemeSettings(context),
                    icon: const Icon(Icons.palette_outlined, size: 20),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(context, NoAnimationPageRoute(builder: (_) => const BookmarksScreen()));
                    },
                    icon: const Icon(Icons.bookmark_outline, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(context, NoAnimationPageRoute(builder: (_) => const SearchScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text("Hikaroka andininy...", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tenin'Andriamanitra:", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 4),
                Text('"${selectedVerse['text']}"', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, fontStyle: FontStyle.italic, height: 1.3)),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(selectedVerse['ref']!, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
      builder: (_) => const ThemeSettingsSheet(),
    ).then((_) => onRefresh());
  }
}
