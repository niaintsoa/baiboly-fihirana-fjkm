import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/data/models/hymn_verse_model.dart';
import 'package:baiboly_apk/data/repositories/fihirana_repository.dart';

abstract class HymnDetailState {}

class HymnDetailInitial extends HymnDetailState {}

class HymnDetailLoading extends HymnDetailState {}

class HymnDetailLoaded extends HymnDetailState {
  final HymnModel hymn;
  final List<HymnVerseModel> verses;
  final bool isBookmarked;

  HymnDetailLoaded({
    required this.hymn,
    required this.verses,
    required this.isBookmarked,
  });
}

class HymnDetailError extends HymnDetailState {
  final String message;
  HymnDetailError(this.message);
}

class HymnDetailCubit extends Cubit<HymnDetailState> {
  final FihiranaRepository _repository;

  HymnDetailCubit(this._repository) : super(HymnDetailInitial());

  Future<void> loadHymnDetails(HymnModel hymn) async {
    emit(HymnDetailLoading());
    try {
      final verses = await _repository.getHymnVerses(hymn.id);
      final isBookmarked = await _repository.isBookmarked(hymn.id);
      emit(HymnDetailLoaded(
        hymn: hymn,
        verses: verses,
        isBookmarked: isBookmarked,
      ));
    } catch (e) {
      emit(HymnDetailError("Tsy voavakina ny andininy: $e"));
    }
  }

  Future<void> toggleHymnBookmark(int hymnId) async {
    try {
      await _repository.toggleBookmark(hymnId);
      final currentState = state;
      if (currentState is HymnDetailLoaded && currentState.hymn.id == hymnId) {
        final isBookmarked = await _repository.isBookmarked(hymnId);
        emit(HymnDetailLoaded(
          hymn: currentState.hymn,
          verses: currentState.verses,
          isBookmarked: isBookmarked,
        ));
      }
    } catch (_) {}
  }
}
