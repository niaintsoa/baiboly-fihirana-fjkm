import 'package:baiboly_apk/data/database/bible_database_helper.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/bookmark_model.dart';

class BibleRepository {
  final BibleDatabaseHelper _dbHelper = BibleDatabaseHelper.instance;

  Future<List<BookModel>> getBooks() async {
    return await _dbHelper.getBooks();
  }

  Future<List<VerseModel>> getVerses(int bookNumber, int chapter) async {
    return await _dbHelper.getVerses(bookNumber, chapter);
  }

  Future<List<VerseModel>> searchVerses(String query) async {
    return await _dbHelper.searchVerses(query);
  }

  Future<List<BookmarkModel>> getBookmarks() async {
    return await _dbHelper.getBookmarks();
  }

  Future<bool> isBookmarked(int bookNumber, int chapter, int verse) async {
    return await _dbHelper.isBookmarked(bookNumber, chapter, verse);
  }

  Future<void> toggleBookmark(VerseModel verse) async {
    await _dbHelper.toggleBookmark(verse);
  }
}
