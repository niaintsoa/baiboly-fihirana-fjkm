import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiboly_apk/data/models/fandaharana_item.dart';

abstract class FandaharanaState {
  const FandaharanaState();
}

class FandaharanaInitial extends FandaharanaState {}

class FandaharanaLoaded extends FandaharanaState {
  final List<FandaharanaItem> items;

  const FandaharanaLoaded(this.items);
}

class FandaharanaCubit extends Cubit<FandaharanaState> {
  static const _programKey = 'fandaharana_items';

  FandaharanaCubit() : super(FandaharanaInitial()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList(_programKey) ?? [];
      final items = itemsJson
          .map((json) => FandaharanaItem.fromMap(jsonDecode(json) as Map<String, dynamic>))
          .toList();
      emit(FandaharanaLoaded(items));
    } catch (e) {
      emit(const FandaharanaLoaded([]));
    }
  }

  Future<void> addItem(FandaharanaItem item) async {
    try {
      final currentState = state;
      List<FandaharanaItem> currentItems = [];
      if (currentState is FandaharanaLoaded) {
        currentItems = List.from(currentState.items);
      }

      // Add to end of program
      currentItems.add(item);

      final prefs = await SharedPreferences.getInstance();
      final itemStrings =
          currentItems.map((i) => jsonEncode(i.toMap())).toList();
      await prefs.setStringList(_programKey, itemStrings);

      emit(FandaharanaLoaded(currentItems));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> removeItem(String id) async {
    try {
      final currentState = state;
      if (currentState is FandaharanaLoaded) {
        final currentItems = List<FandaharanaItem>.from(currentState.items);
        currentItems.removeWhere((item) => item.id == id);

        final prefs = await SharedPreferences.getInstance();
        final itemStrings =
            currentItems.map((i) => jsonEncode(i.toMap())).toList();
        await prefs.setStringList(_programKey, itemStrings);

        emit(FandaharanaLoaded(currentItems));
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> clearItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_programKey);
      emit(const FandaharanaLoaded([]));
    } catch (e) {
      // Ignore
    }
  }
}
