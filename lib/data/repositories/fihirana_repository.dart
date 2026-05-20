import 'package:baiboly_apk/data/database/fihirana_database_helper.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/data/models/hymn_verse_model.dart';

class FihiranaRepository {
  final FihiranaDatabaseHelper _dbHelper = FihiranaDatabaseHelper.instance;

  Future<List<HymnModel>> getHymnsByCategory(String category) async {
    return await _dbHelper.getHymnsByCategory(category);
  }

  Future<List<HymnVerseModel>> getHymnVerses(int hymnId) async {
    return await _dbHelper.getHymnVerses(hymnId);
  }

  Future<List<HymnModel>> searchHymns(String query) async {
    return await _dbHelper.searchHymns(query);
  }

  Future<List<HymnModel>> getBookmarks() async {
    return await _dbHelper.getBookmarkedHymns();
  }

  Future<bool> isBookmarked(int hymnId) async {
    return await _dbHelper.isBookmarked(hymnId);
  }

  Future<void> toggleBookmark(int hymnId) async {
    await _dbHelper.toggleBookmark(hymnId);
  }
}
