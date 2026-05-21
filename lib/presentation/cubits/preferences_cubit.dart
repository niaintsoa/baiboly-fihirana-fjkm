import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState {
  final String themeMode; // 'light', 'sepia', 'dark'
  final double fontSize; // default 18.0
  final double lineSpacing; // default 1.5
  final int primaryColorValue; // default 0xFF8B2635
  final bool dailyReadingEnabled;
  final bool dailyWorshipEnabled;
  final String dailyReadingTime; // HH:mm format
  final String dailyWorshipTime; // HH:mm format

  PreferencesState({
    required this.themeMode,
    required this.fontSize,
    required this.lineSpacing,
    required this.primaryColorValue,
    this.dailyReadingEnabled = false,
    this.dailyWorshipEnabled = false,
    this.dailyReadingTime = '',
    this.dailyWorshipTime = '',
  });

  PreferencesState copyWith({
    String? themeMode,
    double? fontSize,
    double? lineSpacing,
    int? primaryColorValue,
    bool? dailyReadingEnabled,
    bool? dailyWorshipEnabled,
    String? dailyReadingTime,
    String? dailyWorshipTime,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      dailyReadingEnabled: dailyReadingEnabled ?? this.dailyReadingEnabled,
      dailyWorshipEnabled: dailyWorshipEnabled ?? this.dailyWorshipEnabled,
      dailyReadingTime: dailyReadingTime ?? this.dailyReadingTime,
      dailyWorshipTime: dailyWorshipTime ?? this.dailyWorshipTime,
    );
  }


}

class PreferencesCubit extends Cubit<PreferencesState> {
  static const String _themeKey = 'prefs_theme_mode';
  static const String _fontSizeKey = 'prefs_font_size';
  static const String _lineSpacingKey = 'prefs_line_spacing';
  static const String _primaryColorKey = 'prefs_primary_color_value';
  static const String _dailyReadingKey = 'prefs_daily_reading_enabled';
  static const String _dailyWorshipKey = 'prefs_daily_worship_enabled';
  static const String _readingTimeKey = 'prefs_daily_reading_time';
  static const String _worshipTimeKey = 'prefs_daily_worship_time';

  PreferencesCubit()
      : super(PreferencesState(
          themeMode: 'light',
          fontSize: 18.0,
          lineSpacing: 1.5,
          primaryColorValue: 0xFF8B2635,
        )) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey) ?? 'light';
    final fontSize = prefs.getDouble(_fontSizeKey) ?? 18.0;
    final lineSpacing = prefs.getDouble(_lineSpacingKey) ?? 1.5;
    final primaryColor = prefs.getInt(_primaryColorKey) ?? 0xFF8B2635;
    final dailyReading = prefs.getBool(_dailyReadingKey) ?? false;
    final dailyWorship = prefs.getBool(_dailyWorshipKey) ?? false;
    final readingTime = prefs.getString(_readingTimeKey) ?? '';
    final worshipTime = prefs.getString(_worshipTimeKey) ?? '';

    emit(PreferencesState(
      themeMode: theme,
      fontSize: fontSize,
      lineSpacing: lineSpacing,
      primaryColorValue: primaryColor,
      dailyReadingEnabled: dailyReading,
      dailyWorshipEnabled: dailyWorship,
      dailyReadingTime: readingTime,
      dailyWorshipTime: worshipTime,
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

  Future<void> setDailyReadingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReadingKey, enabled);
    emit(state.copyWith(dailyReadingEnabled: enabled));
  }

  Future<void> setDailyReadingTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingTimeKey, time);
    emit(state.copyWith(dailyReadingTime: time));
  }

  Future<void> setDailyWorshipEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyWorshipKey, enabled);
    emit(state.copyWith(dailyWorshipEnabled: enabled));
  }

  Future<void> setDailyWorshipTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_worshipTimeKey, time);
    emit(state.copyWith(dailyWorshipTime: time));
  }

  Future<void> setPrimaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, colorValue);
    emit(state.copyWith(primaryColorValue: colorValue));
  }
}
