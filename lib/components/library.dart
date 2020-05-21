import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A library of user marked words
///

class WordLibrary {
  Set<String> _words;

  final _dbTableName = "user_library";

  WordLibrary() {
    _words = Set();
  }

  void addWord(String word) {
    _words.add(word.toLowerCase());
  }
  Set<String> get words => _words;

  // connect to user library database
  get _database async {
    return await openDatabase(
      join(await getDatabasesPath(), 'user_library.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE "+ _dbTableName +"(word VARCHAR PRIMARY KEY)",
        );
      },
      version: 1
    );
  }

  Future<void> saveToDatabase() async {
    Database db = await _database;
    _words.forEach((word) async {
      await db.insert(_dbTableName,
        {
          'word': word
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> loadFromDatabase() async {
    Database db = await _database;

    // Query the table for all The Words.
    final List<Map<String, dynamic>> maps = await db.query(_dbTableName);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    _words = Set();

    for (var i = 0; i < maps.length ; i ++ ){
      _words.add(maps[i]['word']);
    }
  }
}