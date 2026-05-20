import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';

abstract class BibleReaderState {}

class BibleReaderInitial extends BibleReaderState {}

class BibleReaderLoading extends BibleReaderState {}

class BibleReaderLoaded extends BibleReaderState {
  final List<BookModel> books;
  final BookModel currentBook;
  final int currentChapter;
  final List<VerseModel> verses;

  BibleReaderLoaded({
    required this.books,
    required this.currentBook,
    required this.currentChapter,
    required this.verses,
  });
}

class BibleReaderError extends BibleReaderState {
  final String message;
  BibleReaderError(this.message);
}

class BibleReaderCubit extends Cubit<BibleReaderState> {
  final BibleRepository _repository;
  List<BookModel> _books = [];

  BibleReaderCubit(this._repository) : super(BibleReaderInitial());

  Future<void> loadChapter(BookModel book, int chapter) async {
    emit(BibleReaderLoading());
    try {
      if (_books.isEmpty) {
        _books = await _repository.getBooks();
      }
      final verses = await _repository.getVerses(book.number, chapter);
      emit(BibleReaderLoaded(
        books: _books,
        currentBook: book,
        currentChapter: chapter,
        verses: verses,
      ));
    } catch (e) {
      emit(BibleReaderError("Tsy voavakina ny andininy: $e"));
    }
  }

  Future<void> nextChapter() async {
    final currentState = state;
    if (currentState is BibleReaderLoaded) {
      final currentBook = currentState.currentBook;
      final currentChapter = currentState.currentChapter;

      if (currentChapter < currentBook.totalChapters) {
        await loadChapter(currentBook, currentChapter + 1);
      } else {
        final currentIndex = _books.indexWhere((b) => b.number == currentBook.number);
        if (currentIndex != -1 && currentIndex < _books.length - 1) {
          await loadChapter(_books[currentIndex + 1], 1);
        }
      }
    }
  }

  Future<void> previousChapter() async {
    final currentState = state;
    if (currentState is BibleReaderLoaded) {
      final currentBook = currentState.currentBook;
      final currentChapter = currentState.currentChapter;

      if (currentChapter > 1) {
        await loadChapter(currentBook, currentChapter - 1);
      } else {
        final currentIndex = _books.indexWhere((b) => b.number == currentBook.number);
        if (currentIndex != -1 && currentIndex > 0) {
          final prevBook = _books[currentIndex - 1];
          await loadChapter(prevBook, prevBook.totalChapters);
        }
      }
    }
  }
}
