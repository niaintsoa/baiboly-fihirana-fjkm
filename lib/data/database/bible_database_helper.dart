import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:baiboly_apk/data/models/book_model.dart';
import 'package:baiboly_apk/data/models/verse_model.dart';
import 'package:baiboly_apk/data/models/bookmark_model.dart';

class BibleDatabaseHelper {
  static final BibleDatabaseHelper instance = BibleDatabaseHelper._init();
  static Database? _database;

  BibleDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('baiboly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print("BibleDatabaseHelper: Chemin de la base de données local : $path");

    // Vérifie si la base de données existe localement dans les documents
    final exists = await databaseExists(path);
    print("BibleDatabaseHelper: La base de données existe localement ? $exists");

    if (!exists) {
      print("BibleDatabaseHelper: La base de données n'existe pas localement. Copie depuis les assets...");
      try {
        await Directory(dirname(path)).create(recursive: true);
        
        ByteData data = await rootBundle.load('assets/database/$filePath');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        
        await File(path).writeAsBytes(bytes, flush: true);
        print("BibleDatabaseHelper: Copie depuis les assets réussie.");
      } catch (e) {
        print("BibleDatabaseHelper: Erreur de copie de l'asset. Création d'une base de démo. Erreur : $e");
        return await _createDemoDatabase(path);
      }
    }

    var db = await openDatabase(path);
    
    // Vérification de sécurité : si c'est la base de démo (qui contient moins de 66 livres),
    // on force la copie de la vraie base de données depuis les assets.
    try {
      final booksCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM books')) ?? 0;
      print("BibleDatabaseHelper: Nombre de livres trouvés dans la base actuelle : $booksCount");
      if (booksCount < 66) {
        print("BibleDatabaseHelper: Nombre de livres ($booksCount) inférieur à 66. Remplacement par la base complète des assets...");
        await db.close();
        
        // Supprimer l'ancienne base pour éviter tout verrouillage
        try {
          await File(path).delete();
          print("BibleDatabaseHelper: Ancienne base de données supprimée avec succès.");
        } catch (e) {
          print("BibleDatabaseHelper: Impossible de supprimer l'ancienne base de données : $e");
        }

        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load('assets/database/$filePath');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        print("BibleDatabaseHelper: Base complète copiée depuis les assets.");
        
        db = await openDatabase(path);
      }
    } catch (e) {
      print("BibleDatabaseHelper: Erreur lors de la lecture ou vérification du nombre de livres : $e");
      // Si la table 'books' n'existe pas, on tente de forcer la copie également
      try {
        await db.close();
        try {
          await File(path).delete();
        } catch (_) {}
        
        ByteData data = await rootBundle.load('assets/database/$filePath');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        print("BibleDatabaseHelper: Base de données copiée après erreur de table.");
        db = await openDatabase(path);
      } catch (err) {
        print("BibleDatabaseHelper: Échec critique de la copie après erreur de table : $err. Remplissage par les données de secours.");
        db = await openDatabase(path);
        await _populateDemoData(db);
      }
    }

    await _createTablesIfNotExist(db);
    return db;
  }

  // Injecte les données de secours si la base est vide et qu'on ne peut pas charger l'asset
  Future<void> _populateDemoData(Database db) async {
    print("BibleDatabaseHelper: Remplissage avec les données de démonstration de secours...");
    await db.execute('DROP TABLE IF EXISTS books');
    await db.execute('DROP TABLE IF EXISTS verses');

    // Table des livres
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number INTEGER UNIQUE,
        name TEXT NOT NULL,
        testament TEXT NOT NULL,
        chapters INTEGER NOT NULL
      )
    ''');

    // Table des versets
    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_number INTEGER,
        chapter INTEGER,
        verse INTEGER,
        text TEXT NOT NULL,
        FOREIGN KEY (book_number) REFERENCES books (number)
      )
    ''');

    // Indexation
    await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_book_chapter ON verses (book_number, chapter)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_text ON verses (text)');

    // Livres de démonstration
    await db.insert('books', {'number': 1, 'name': 'Genesisy', 'testament': 'Old', 'chapters': 2});
    await db.insert('books', {'number': 40, 'name': 'Matio', 'testament': 'New', 'chapters': 2});

    // Versets Genesisy 1 (1-5)
    final gen1Verses = [
      "Amin'ny voalohany Andriamanitra nahary ny lanitra sy ny tany.",
      "Ary ny tany dia tsy nisy endrika sady foana; ary aizina no tambonin'ny lalina. Ary ny Fanahin'Andriamanitra nanidina tambonin'ny rano.",
      "Ary Andriamanitra nanao hoe: Hahazava; dia nisy mazava.",
      "Ary hitan'Andriamanitra ny mazava fa tsara; ary nampisarahan'Andriamanitra ny mazava sy ny aizina.",
      "Ary Andriamanitra nanao ny mazava hoe Andro, ary ny aizina nataony hoe Alina. Dia nisy hariva, ary nisy maraina, dia andro voalohany izany."
    ];
    for (int i = 0; i < gen1Verses.length; i++) {
      await db.insert('verses', {
        'book_number': 1,
        'chapter': 1,
        'verse': i + 1,
        'text': gen1Verses[i]
      });
    }

    // Versets Matio 1 (1-3)
    final mat1Verses = [
      "Ny bokin'ny taranak'i Jesosy Kristy, zanak'i Davida, zanak'i Abrahama.",
      "Abrahama niteraka an'Isaaka; ary Isaaka niteraka an'i Jakoba; ary Jakoba niteraka an'i Joda sy ny rahalahiny;",
      "ary Joda niteraka an'i Farez sy an'i Zara tamin'i Tamara; ary Farez niteraka an'i Esroma; ary Esroma niteraka an'i Arama;"
    ];
    for (int i = 0; i < mat1Verses.length; i++) {
      await db.insert('verses', {
        'book_number': 40,
        'chapter': 1,
        'verse': i + 1,
        'text': mat1Verses[i]
      });
    }
    print("BibleDatabaseHelper: Remplissage de secours terminé.");
  }

  // Crée des tables de secours et des données de démo si l'asset SQL n'est pas encore là
  Future<Database> _createDemoDatabase(String path) async {
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _populateDemoData(db);
      },
    );
  }

  // Crée les tables nécessaires (favoris, historique, etc.) si elles n'existent pas
  Future<void> _createTablesIfNotExist(Database db) async {
    // Crée la table des favoris (bookmarks) si elle n'existe pas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_number INTEGER NOT NULL,
        book_name TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // On s'assure aussi de créer les index si la BD importée de l'utilisateur n'en possède pas
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_book_chapter ON verses (book_number, chapter)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_verses_text ON verses (text)');
    } catch (_) {
      // Ignorer si les tables verses n'existent pas ou ont des colonnes différentes
      // (sera ajusté quand l'utilisateur fournira sa base de données)
    }
  }

  // Obtenir tous les livres
  Future<List<BookModel>> getBooks() async {
    final db = await instance.database;
    
    // Détecte les colonnes de la table "books" ou équivalent
    List<Map<String, dynamic>> result = [];
    try {
      result = await db.query('books', orderBy: 'number ASC');
    } catch (e) {
      // Si la table books n'existe pas mais qu'il y a une table verses, on peut essayer d'en déduire les livres,
      // ou de renvoyer une liste vide. Mais pour l'instant on suppose la table books présente ou démo.
      result = [];
    }

    return result.map((json) => BookModel.fromMap(json)).toList();
  }

  // Obtenir les versets d'un chapitre spécifique d'un livre
  Future<List<VerseModel>> getVerses(int bookNumber, int chapter) async {
    final db = await instance.database;
    
    // Récupérer le nom du livre pour le lier au modèle de verset
    String bookName = 'Book $bookNumber';
    try {
      final bookResult = await db.query('books', where: 'number = ?', whereArgs: [bookNumber], limit: 1);
      if (bookResult.isNotEmpty) {
        bookName = bookResult.first['name'] as String? ?? 'Book $bookNumber';
      }
    } catch (_) {}

    final List<Map<String, dynamic>> result = await db.query(
      'verses',
      where: 'book_number = ? AND chapter = ?',
      whereArgs: [bookNumber, chapter],
      orderBy: 'verse ASC',
    );

    return result.map((json) => VerseModel.fromMap(json, defaultBookName: bookName)).toList();
  }

  // Recherche plein texte
  Future<List<VerseModel>> searchVerses(String query) async {
    if (query.trim().isEmpty) return [];

    final db = await instance.database;
    
    // Recherche par mot clé dans la base de données
    // Pour être très rapide, on utilise LIKE indexé ou MATCH si configuré
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT v.*, b.name as book_name 
      FROM verses v
      LEFT JOIN books b ON v.book_number = b.number
      WHERE v.text LIKE ?
      LIMIT 100
    ''', ['%$query%']);

    return result.map((json) => VerseModel.fromMap(json)).toList();
  }

  // --- Gestion des Favoris ---

  Future<List<BookmarkModel>> getBookmarks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query('bookmarks', orderBy: 'created_at DESC');
    return result.map((json) => BookmarkModel.fromMap(json)).toList();
  }

  Future<bool> isBookmarked(int bookNumber, int chapter, int verse) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'bookmarks',
      where: 'book_number = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookNumber, chapter, verse],
    );
    return result.isNotEmpty;
  }

  Future<void> toggleBookmark(VerseModel verse) async {
    final db = await instance.database;
    final bookmarked = await isBookmarked(verse.bookNumber, verse.chapter, verse.verse);

    if (bookmarked) {
      await db.delete(
        'bookmarks',
        where: 'book_number = ? AND chapter = ? AND verse = ?',
        whereArgs: [verse.bookNumber, verse.chapter, verse.verse],
      );
    } else {
      await db.insert('bookmarks', {
        'book_number': verse.bookNumber,
        'book_name': verse.bookName,
        'chapter': verse.chapter,
        'verse': verse.verse,
        'text': verse.text,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<VerseModel?> getRandomVerse() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT v.*, b.name as book_name 
      FROM verses v
      LEFT JOIN books b ON v.book_number = b.number
      ORDER BY RANDOM()
      LIMIT 1
    ''');
    if (result.isEmpty) return null;
    return VerseModel.fromMap(result.first);
  }
}
