import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  Text("Haben'ny soratra", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
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
              Text("Loko ambadika", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(context, 'light', 'Mamazava', const Color(0xFFFDFBF7), const Color(0xFF2C2520), prefs.themeMode),
                  _buildOption(context, 'sepia', 'Sepia', const Color(0xFFF4ECD8), const Color(0xFF3E2723), prefs.themeMode),
                  _buildOption(context, 'dark', 'Maizina', const Color(0xFF141416), const Color(0xFFE3E3E6), prefs.themeMode),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, String value, String label, Color bg, Color txt, String current) {
    final isSel = current == value;
    return InkWell(
      onTap: () => context.read<PreferencesCubit>().setThemeMode(value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSel ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
            width: isSel ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text("Aa", style: TextStyle(color: txt, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: txt.withOpacity(0.8), fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
