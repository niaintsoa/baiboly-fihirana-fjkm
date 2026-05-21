import 'package:flutter/material.dart';
import 'package:baiboly_apk/presentation/screens/bookmarks_screen.dart';
import 'package:baiboly_apk/presentation/screens/search_screen.dart';
import 'package:baiboly_apk/presentation/widgets/theme_settings_sheet.dart';
import 'package:baiboly_apk/presentation/navigation/no_animation_route.dart';

class BibleHomeHeader extends StatelessWidget {
  final Map<String, String> selectedVerse;
  final VoidCallback onRefresh;
  final bool showWordOfGod;

  const BibleHomeHeader({
    super.key,
    required this.selectedVerse,
    required this.onRefresh,
    this.showWordOfGod = true,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "BAIBOLY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "FFPM",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 12),
                    onPressed: () => _showThemeSettings(context),
                    icon: Icon(Icons.palette_outlined, size: 22, color: theme.colorScheme.primary),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(context, NoAnimationPageRoute(builder: (_) => const BookmarksScreen()));
                    },
                    icon: Icon(Icons.bookmark_outline, size: 22, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(context, NoAnimationPageRoute(builder: (_) => const SearchScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    "Hikaroka andininy...",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showWordOfGod) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tenin'Andriamanitra:", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 6),
                  Text('"${selectedVerse['text']}"', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, fontStyle: FontStyle.italic, height: 1.4, color: Colors.white)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(selectedVerse['ref']!, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
                  ),
                ],
              ),
            ),
          ],
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
