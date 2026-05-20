import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState {
  final String themeMode; // 'light', 'sepia', 'dark'
  final double fontSize;  // par défaut 16.0
  final double lineSpacing; // par défaut 1.5

  PreferencesState({
    required this.themeMode,
    required this.fontSize,
    required this.lineSpacing,
  });

  PreferencesState copyWith({
    String? themeMode,
    double? fontSize,
    double? lineSpacing,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
    );
  }
}

class PreferencesCubit extends Cubit<PreferencesState> {
  static const String _themeKey = 'prefs_theme_mode';
  static const String _fontSizeKey = 'prefs_font_size';
  static const String _lineSpacingKey = 'prefs_line_spacing';

  PreferencesCubit()
      : super(PreferencesState(themeMode: 'light', fontSize: 18.0, lineSpacing: 1.5)) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey) ?? 'light';
    final fontSize = prefs.getDouble(_fontSizeKey) ?? 18.0;
    final lineSpacing = prefs.getDouble(_lineSpacingKey) ?? 1.5;

    emit(PreferencesState(
      themeMode: theme,
      fontSize: fontSize,
      lineSpacing: lineSpacing,
    ));
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setFontSize(double size) async {
    if (size < 12.0 || size > 36.0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
    emit(state.copyWith(fontSize: size));
  }

  Future<void> increaseFontSize() async {
    await setFontSize(state.fontSize + 2.0);
  }

  Future<void> decreaseFontSize() async {
    await setFontSize(state.fontSize - 2.0);
  }

  Future<void> setLineSpacing(double spacing) async {
    if (spacing < 1.0 || spacing > 2.5) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineSpacingKey, spacing);
    emit(state.copyWith(lineSpacing: spacing));
  }
}
