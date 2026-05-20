import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/data/repositories/fihirana_repository.dart';

abstract class FihiranaState {}

class FihiranaInitial extends FihiranaState {}

class FihiranaLoading extends FihiranaState {}

class FihiranaLoaded extends FihiranaState {
  final List<HymnModel> hymns;
  final String category;
  FihiranaLoaded(this.hymns, this.category);
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

  Future<void> loadHymns(String category) async {
    emit(FihiranaLoading());
    try {
      final hymns = await _repository.getHymnsByCategory(category);
      emit(FihiranaLoaded(hymns, category));
    } catch (e) {
      emit(FihiranaError("Tsy voavakina ny fihirana: $e"));
    }
  }

  Future<void> toggleHymnBookmark(int hymnId) async {
    try {
      await _repository.toggleBookmark(hymnId);
      if (state is FihiranaBookmarksLoaded) {
        loadBookmarks();
      }
    } catch (_) {}
  }

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
