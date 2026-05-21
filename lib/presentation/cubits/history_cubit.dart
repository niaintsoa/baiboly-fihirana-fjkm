import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiboly_apk/data/models/history_item.dart';

abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<HistoryItem> history;

  const HistoryLoaded(this.history);
}

class HistoryCubit extends Cubit<HistoryState> {
  static const _historyKey = 'reader_history';

  HistoryCubit() : super(HistoryInitial()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      final history = historyJson
          .map((json) => HistoryItem.fromMap(jsonDecode(json) as Map<String, dynamic>))
          .toList();
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(const HistoryLoaded([]));
    }
  }

  Future<void> addItem(HistoryItem item) async {
    try {
      final currentState = state;
      List<HistoryItem> currentHistory = [];
      if (currentState is HistoryLoaded) {
        currentHistory = List.from(currentState.history);
      }

      // Remove duplicate if exists
      currentHistory.removeWhere((i) =>
          i.bookNumber == item.bookNumber &&
          i.chapter == item.chapter &&
          i.verse == item.verse);

      // Add to beginning
      currentHistory.insert(0, item);

      // Keep only last 50 items
      if (currentHistory.length > 50) {
        currentHistory = currentHistory.take(50).toList();
      }

      final prefs = await SharedPreferences.getInstance();
      final historyStrings =
          currentHistory.map((item) => jsonEncode(item.toMap())).toList();
      await prefs.setStringList(_historyKey, historyStrings);

      emit(HistoryLoaded(currentHistory));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> deleteItem(HistoryItem item) async {
    try {
      final currentState = state;
      if (currentState is HistoryLoaded) {
        final currentHistory = List<HistoryItem>.from(currentState.history);
        currentHistory.remove(item);

        final prefs = await SharedPreferences.getInstance();
        final historyStrings =
            currentHistory.map((item) => jsonEncode(item.toMap())).toList();
        await prefs.setStringList(_historyKey, historyStrings);

        emit(HistoryLoaded(currentHistory));
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      emit(const HistoryLoaded([]));
    } catch (e) {
      // Ignore
    }
  }
}
