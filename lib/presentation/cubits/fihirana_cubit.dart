import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/data/models/hymn_verse_model.dart';
import 'package:baiboly_apk/data/repositories/fihirana_repository.dart';

abstract class FihiranaState {}

class FihiranaInitial extends FihiranaState {}

class FihiranaLoading extends FihiranaState {}

class FihiranaLoaded extends FihiranaState {
  final List<HymnModel> hymns;
  final String category;
  FihiranaLoaded(this.hymns, this.category);
}

class HymnLoaded extends FihiranaState {
  final HymnModel hymn;
  final List<HymnVerseModel> verses;
  final bool isBookmarked;

  HymnLoaded({
    required this.hymn,
    required this.verses,
    required this.isBookmarked,
  });
}

class FihiranaBookmarksLoaded extends FihiranaState {
  final List<HymnModel> bookmarks;
  FihiranaBookmarksLoaded(this.bookmarks);
}

class FihiranaError extends FihiranaState {
  final String message;
  FihiranaError(this.message);
}

class FihiranaCubit extends Cubit<FihiranaState> {
  final FihiranaRepository _repository;

  FihiranaCubit(this._repository) : super(FihiranaInitial());

  // Charger les cantiques par catégorie
  Future<void> loadHymns(String category) async {
    emit(FihiranaLoading());
    try {
      final hymns = await _repository.getHymnsByCategory(category);
      emit(FihiranaLoaded(hymns, category));
    } catch (e) {
      emit(FihiranaError("Tsy voavakina ny fihirana: $e"));
    }
  }

  // Charger les détails d'un cantique (couplets + favoris)
  Future<void> loadHymnDetails(HymnModel hymn) async {
    emit(FihiranaLoading());
    try {
      final verses = await _repository.getHymnVerses(hymn.id);
      final isBookmarked = await _repository.isBookmarked(hymn.id);
      emit(HymnLoaded(
        hymn: hymn,
        verses: verses,
        isBookmarked: isBookmarked,
      ));
    } catch (e) {
      emit(FihiranaError("Tsy voavakina ny andininy: $e"));
    }
  }

  // Ajouter / Enlever des favoris
  Future<void> toggleHymnBookmark(int hymnId) async {
    try {
      await _repository.toggleBookmark(hymnId);
      final currentState = state;
      if (currentState is HymnLoaded && currentState.hymn.id == hymnId) {
        final isBookmarked = await _repository.isBookmarked(hymnId);
        emit(HymnLoaded(
          hymn: currentState.hymn,
          verses: currentState.verses,
          isBookmarked: isBookmarked,
        ));
      } else if (currentState is FihiranaBookmarksLoaded) {
        loadBookmarks();
      }
    } catch (e) {
      print("Erreur favori fihirana : $e");
    }
  }

  // Charger tous les favoris
  Future<void> loadBookmarks() async {
    emit(FihiranaLoading());
    try {
      final bookmarks = await _repository.getBookmarks();
      emit(FihiranaBookmarksLoaded(bookmarks));
    } catch (e) {
      emit(FihiranaError("Tsy voavakina ny favori: $e"));
    }
  }
}
