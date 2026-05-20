import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';

abstract class BibleState {}

class BibleInitial extends BibleState {}

class BibleLoading extends BibleState {}

class BibleBooksLoaded extends BibleState {
  final List<BookModel> books;
  BibleBooksLoaded(this.books);
}

class BibleError extends BibleState {
  final String message;
  BibleError(this.message);
}

class BibleCubit extends Cubit<BibleState> {
  final BibleRepository _repository;

  BibleCubit(this._repository) : super(BibleInitial());

  Future<void> loadBooks() async {
    emit(BibleLoading());
    try {
      final books = await _repository.getBooks();
      emit(BibleBooksLoaded(books));
    } catch (e) {
      emit(BibleError("Tsy voavakina ny boky: $e"));
    }
  }
}
