import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:baiboly_apk/data/models/hymn_model.dart';
import 'package:baiboly_apk/data/models/hymn_verse_model.dart';

class FihiranaDatabaseHelper {
  static final FihiranaDatabaseHelper instance = FihiranaDatabaseHelper._init();
  static Database? _database;

  FihiranaDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fihirana.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    debugPrint("FihiranaDatabaseHelper: Chemin de la base de données locale : $path");

    final exists = await databaseExists(path);
    debugPrint("FihiranaDatabaseHelper: La base de données existe localement ? $exists");

    if (!exists) {
      debugPrint("FihiranaDatabaseHelper: La base de données n'existe pas localement. Copie depuis les assets...");
      try {
        await Directory(dirname(path)).create(recursive: true);
        
        ByteData data = await rootBundle.load('assets/database/$filePath');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        
        await File(path).writeAsBytes(bytes, flush: true);
        debugPrint("FihiranaDatabaseHelper: Copie depuis les assets réussie.");
      } catch (e) {
        debugPrint("FihiranaDatabaseHelper: Erreur de copie de l'asset. Création d'une base de démo. Erreur : $e");
        return await _createDemoDatabase(path);
      }
    }

    var db = await openDatabase(path);

    // Vérification de sécurité : si c'est la base de démo ou incomplète, on force la copie de la vraie base de données depuis les assets.
    try {
      final hymnsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM hymns')) ?? 0;
      debugPrint("FihiranaDatabaseHelper: Nombre de cantiques trouvés dans la base actuelle : $hymnsCount");
      if (hymnsCount < 800) {
        debugPrint("FihiranaDatabaseHelper: Nombre de cantiques ($hymnsCount) inférieur au minimum attendu. Remplacement par la base complète des assets...");
        await db.close();
        
        try {
          await File(path).delete();
          debugPrint("FihiranaDatabaseHelper: Ancienne base de données supprimée.");
        } catch (e) {
          debugPrint("FihiranaDatabaseHelper: Impossible de supprimer la base actuelle : $e");
        }

        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load('assets/database/$filePath');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        debugPrint("FihiranaDatabaseHelper: Base complète copiée depuis les assets.");
        
        db = await openDatabase(path);
      }
    } catch (e) {
      debugPrint("FihiranaDatabaseHelper: Erreur lors de la lecture ou vérification. Force la copie...");
      try {
        await db.close();
        try {
          await File(path).delete();
        } catch (_) {}
        
        ByteData data = await rootBundle.load('assets/database/$filePath');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        db = await openDatabase(path);
      } catch (err) {
        debugPrint("FihiranaDatabaseHelper: Échec critique de la copie : $err. Remplissage par les données de secours.");
        db = await openDatabase(path);
        await _populateDemoData(db);
      }
    }

    await _createTablesIfNotExist(db);
    return db;
  }

  Future<void> _createTablesIfNotExist(Database db) async {
    // S'assurer de la présence de la table des favoris
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hymn_bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_id INTEGER UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (hymn_id) REFERENCES hymns (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<Database> _createDemoDatabase(String path) async {
    var db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await _populateDemoData(db);
    });
    return db;
  }

  Future<void> _populateDemoData(Database db) async {
    debugPrint("FihiranaDatabaseHelper: Remplissage avec les données de démonstration de secours...");
    await db.execute('DROP TABLE IF EXISTS hymns');
    await db.execute('DROP TABLE IF EXISTS verses');
    await db.execute('DROP TABLE IF EXISTS hymn_bookmarks');

    await db.execute('''
      CREATE TABLE hymns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER NOT NULL,
        category TEXT NOT NULL,
        title TEXT,
        author TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_id INTEGER NOT NULL,
        verse_number INTEGER,
        lyrics TEXT NOT NULL,
        is_chorus INTEGER DEFAULT 0,
        FOREIGN KEY (hymn_id) REFERENCES hymns (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE hymn_bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hymn_id INTEGER UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (hymn_id) REFERENCES hymns (id) ON DELETE CASCADE
      )
    ''');

    // Indexation
    await db.execute('CREATE INDEX IF NOT EXISTS idx_hymns_number_category ON hymns (number, category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_hymn_id ON verses (hymn_id)');

    // Chant de démo 1
    int h1 = await db.insert('hymns', {
      'number': 1,
      'category': 'ffpm',
      'title': 'Andriananahary masina indrindra!',
      'author': ''
    });

    await db.insert('verses', {
      'hymn_id': h1,
      'verse_number': 1,
      'lyrics': 'Andriananahary masina indrindra!\nNy anjelinao izay mitoetra Aminao\nMifamaly hoe : Masina indrindra\nAndriananahary, Telo Izay Iray.',
      'is_chorus': 0
    });

    // Chant de démo 2
    int h2 = await db.insert('hymns', {
      'number': 1,
      'category': 'fanampiny',
      'title': 'Mitsangàna ianao ry mino',
      'author': ''
    });

    await db.insert('verses', {
      'hymn_id': h2,
      'verse_number': 1,
      'lyrics': 'Mitsangàna ianao ry mino\nFa ilain\'ny taninao\nNy finoana ifikiro,\nMivonona ianao !',
      'is_chorus': 0
    });
  }

  // --- API Méthodes de requêtes ---

  Future<List<HymnModel>> getHymnsByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'hymns',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'number ASC',
    );
    return result.map((map) => HymnModel.fromMap(map)).toList();
  }

  Future<List<HymnVerseModel>> getHymnVerses(int hymnId) async {
    final db = await database;
    final result = await db.query(
      'verses',
      where: 'hymn_id = ?',
      whereArgs: [hymnId],
      orderBy: 'verse_number ASC, id ASC',
    );
    return result.map((map) => HymnVerseModel.fromMap(map)).toList();
  }

  Future<List<HymnModel>> searchHymns(String query) async {
    final db = await database;
    if (query.trim().isEmpty) return [];

    // Recherche par numéro (si la requête est numérique)
    final intNum = int.tryParse(query.trim());
    if (intNum != null) {
      final numResult = await db.query(
        'hymns',
        where: 'number = ?',
        whereArgs: [intNum],
        orderBy: 'category ASC, number ASC',
      );
      if (numResult.isNotEmpty) {
        return numResult.map((map) => HymnModel.fromMap(map)).toList();
      }
    }

    // Sinon recherche textuelle dans le titre ou les couplets
    final rawQuery = '''
      SELECT DISTINCT h.* FROM hymns h
      LEFT JOIN verses v ON h.id = v.hymn_id
      WHERE h.title LIKE ? OR h.author LIKE ? OR v.lyrics LIKE ?
      ORDER BY h.category ASC, h.number ASC
      LIMIT 100
    ''';
    
    final wildcard = '%$query%';
    final result = await db.rawQuery(rawQuery, [wildcard, wildcard, wildcard]);
    return result.map((map) => HymnModel.fromMap(map)).toList();
  }

  // --- Gestion des Favoris ---

  Future<bool> isBookmarked(int hymnId) async {
    final db = await database;
    final result = await db.query(
      'hymn_bookmarks',
      where: 'hymn_id = ?',
      whereArgs: [hymnId],
    );
    return result.isNotEmpty;
  }

  Future<void> toggleBookmark(int hymnId) async {
    final db = await database;
    final exists = await isBookmarked(hymnId);
    if (exists) {
      await db.delete(
        'hymn_bookmarks',
        where: 'hymn_id = ?',
        whereArgs: [hymnId],
      );
    } else {
      await db.insert('hymn_bookmarks', {
        'hymn_id': hymnId,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<HymnModel>> getBookmarkedHymns() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT h.* FROM hymns h
      INNER JOIN hymn_bookmarks b ON h.id = b.hymn_id
      ORDER BY b.created_at DESC
    ''');
    return result.map((map) => HymnModel.fromMap(map)).toList();
  }
}
