import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/presentation/cubits/preferences_cubit.dart';
import 'package:baiboly_apk/presentation/widgets/color_picker_widget.dart';

class ThemeSettingsSheet extends StatelessWidget {
  const ThemeSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Loko fototra sy ambadika", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          const ColorPickerWidget(),
          const SizedBox(height: 12),
          BlocBuilder<PreferencesCubit, PreferencesState>(
            builder: (context, prefs) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeOption(context, 'light', 'Mamazava', const Color(0xFFFDFBF7), const Color(0xFF2C2520), prefs.themeMode),
                  _buildThemeOption(context, 'sepia', 'Sepia', const Color(0xFFF4ECD8), const Color(0xFF3E2723), prefs.themeMode),
                  _buildThemeOption(context, 'dark', 'Maizina', const Color(0xFF141416), const Color(0xFFE3E3E6), prefs.themeMode),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text("Haben'ny soratra (Polisy)", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          BlocBuilder<PreferencesCubit, PreferencesState>(
            builder: (context, prefs) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: prefs.fontSize > 12 ? () => context.read<PreferencesCubit>().decreaseFontSize() : null,
                    icon: const Icon(Icons.remove, size: 16),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 16),
                  Text("${prefs.fontSize.toInt()}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: prefs.fontSize < 30 ? () => context.read<PreferencesCubit>().increaseFontSize() : null,
                    icon: const Icon(Icons.add, size: 16),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String val, String lbl, Color bg, Color txt, String curr) {
    final isSel = curr == val;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.read<PreferencesCubit>().setThemeMode(val),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSel ? theme.colorScheme.primary : Colors.grey.withOpacity(0.3), width: isSel ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Text("Aa", style: TextStyle(color: txt, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(lbl, style: TextStyle(color: txt.withOpacity(0.8), fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
