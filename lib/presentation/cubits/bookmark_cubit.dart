import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/bookmark_model.dart';
import 'package:baiboly_apk/data/repositories/bible_repository.dart';

abstract class BookmarkState {}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<BookmarkModel> bookmarks;
  BookmarkLoaded(this.bookmarks);
}

class BookmarkError extends BookmarkState {
  final String message;
  BookmarkError(this.message);
}

class BookmarkCubit extends Cubit<BookmarkState> {
  final BibleRepository _repository;

  BookmarkCubit(this._repository) : super(BookmarkInitial());

  Future<void> loadBookmarks() async {
    emit(BookmarkLoading());
    try {
      final bookmarks = await _repository.getBookmarks();
      emit(BookmarkLoaded(bookmarks));
    } catch (e) {
      emit(BookmarkError("Tsy nahomby ny fangalana ny andininy tianao: $e"));
    }
  }

  Future<void> toggleBookmark(VerseModel verse) async {
    try {
      await _repository.toggleBookmark(verse);
      // Recharger la liste après modification
      await loadBookmarks();
    } catch (e) {
      emit(BookmarkError("Tsy nahomby ny fanovana: $e"));
    }
  }

  Future<bool> checkIsBookmarked(VerseModel verse) async {
    return await _repository.isBookmarked(verse.bookNumber, verse.chapter, verse.verse);
  }
}
