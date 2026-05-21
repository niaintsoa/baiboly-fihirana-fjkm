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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC62828), Color(0xFFE53935)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC62828).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Baiboly",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "FFPM",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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
                    icon: Icon(Icons.settings_outlined, size: 20, color: theme.colorScheme.onSurface),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(context, NoAnimationPageRoute(builder: (_) => const BookmarksScreen()));
                    },
                    icon: Icon(Icons.bookmark_outline, size: 20, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(context, NoAnimationPageRoute(builder: (_) => const SearchScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onSurface.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text("Hikaroka andininy...", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
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
