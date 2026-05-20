import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<VerseModel> results;
  final String query;
  SearchSuccess(this.results, this.query);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchCubit extends Cubit<SearchState> {
  final BibleRepository _repository;

  SearchCubit(this._repository) : super(SearchInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final results = await _repository.searchVerses(query);
      emit(SearchSuccess(results, query));
    } catch (e) {
      emit(SearchError("Nisy fahadisoana teo am-pikarohana: $e"));
    }
  }

  void clearSearch() {
    emit(SearchInitial());
  }
}
