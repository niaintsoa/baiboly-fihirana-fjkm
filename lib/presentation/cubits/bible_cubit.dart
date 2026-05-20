import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';

abstract class BibleState {}

class BibleInitial extends BibleState {}

class BibleLoading extends BibleState {}

class BibleBooksLoaded extends BibleState {
  final List<BookModel> books;
  BibleBooksLoaded(this.books);
}

class BibleChapterLoaded extends BibleState {
  final List<BookModel> books;
  final BookModel currentBook;
  final int currentChapter;
  final List<VerseModel> verses;

  BibleChapterLoaded({
    required this.books,
    required this.currentBook,
    required this.currentChapter,
    required this.verses,
  });
}

class BibleError extends BibleState {
  final String message;
  BibleError(this.message);
}

class BibleCubit extends Cubit<BibleState> {
  final BibleRepository _repository;
  List<BookModel> _books = [];

  BibleCubit(this._repository) : super(BibleInitial());

  // Charger tous les livres
  Future<void> loadBooks() async {
    emit(BibleLoading());
    try {
      _books = await _repository.getBooks();
      emit(BibleBooksLoaded(_books));
    } catch (e) {
      emit(BibleError("Tsy voavakina ny boky: $e"));
    }
  }

  // Charger un chapitre particulier
  Future<void> loadChapter(BookModel book, int chapter) async {
    // Si on a déjà chargé les livres ou si la liste est vide, on s'assure qu'elle est dispo
    if (_books.isEmpty) {
      try {
        _books = await _repository.getBooks();
      } catch (e) {
        emit(BibleError("Tsy voavakina ny boky: $e"));
        return;
      }
    }

    emit(BibleLoading());
    try {
      final verses = await _repository.getVerses(book.number, chapter);
      emit(BibleChapterLoaded(
        books: _books,
        currentBook: book,
        currentChapter: chapter,
        verses: verses,
      ));
    } catch (e) {
      emit(BibleError("Tsy voavakina ny andininy: $e"));
    }
  }

  // Naviguer vers le chapitre suivant
  Future<void> nextChapter() async {
    final currentState = state;
    if (currentState is BibleChapterLoaded) {
      final currentBook = currentState.currentBook;
      final currentChapter = currentState.currentChapter;

      if (currentChapter < currentBook.totalChapters) {
        await loadChapter(currentBook, currentChapter + 1);
      } else {
        // Passer au livre suivant
        final currentIndex = _books.indexWhere((b) => b.number == currentBook.number);
        if (currentIndex != -1 && currentIndex < _books.length - 1) {
          final nextBook = _books[currentIndex + 1];
          await loadChapter(nextBook, 1);
        }
      }
    }
  }

  // Naviguer vers le chapitre précédent
  Future<void> previousChapter() async {
    final currentState = state;
    if (currentState is BibleChapterLoaded) {
      final currentBook = currentState.currentBook;
      final currentChapter = currentState.currentChapter;

      if (currentChapter > 1) {
        await loadChapter(currentBook, currentChapter - 1);
      } else {
        // Passer au livre précédent
        final currentIndex = _books.indexWhere((b) => b.number == currentBook.number);
        if (currentIndex != -1 && currentIndex > 0) {
          final prevBook = _books[currentIndex - 1];
          await loadChapter(prevBook, prevBook.totalChapters);
        }
      }
    }
  }
}
