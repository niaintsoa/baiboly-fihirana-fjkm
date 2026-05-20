import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/data/repositories/fihirana_repository.dart';

abstract class FihiranaSearchState {}

class FihiranaSearchInitial extends FihiranaSearchState {}

class FihiranaSearchLoading extends FihiranaSearchState {}

class FihiranaSearchSuccess extends FihiranaSearchState {
  final List<HymnModel> results;
  final String query;
  FihiranaSearchSuccess(this.results, this.query);
}

class FihiranaSearchError extends FihiranaSearchState {
  final String message;
  FihiranaSearchError(this.message);
}

class FihiranaSearchCubit extends Cubit<FihiranaSearchState> {
  final FihiranaRepository _repository;

  FihiranaSearchCubit(this._repository) : super(FihiranaSearchInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(FihiranaSearchInitial());
      return;
    }

    emit(FihiranaSearchLoading());
    try {
      final results = await _repository.searchHymns(query);
      emit(FihiranaSearchSuccess(results, query));
    } catch (e) {
      emit(FihiranaSearchError("Nisy fahadisoana teo am-pikarohana: $e"));
    }
  }

  void clearSearch() {
    emit(FihiranaSearchInitial());
  }
}
