import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A library of user marked words
///

class SingleWord {
  String _word;
  String _definition;
  String synonyms;
  bool isInFavoriteList = false;

  set word(String word) {
    _word = word.toLowerCase();
  }

  set definition(String definition) {
    if (definition == null)
      _definition = "";

    _definition = definition;
  }

  get definition => _definition;
  get word => _word;

  SingleWord({String word, String definition, bool isInFavoriteList, this.synonyms}) {
    this.word = word;
    this.definition = definition;
    if (isInFavoriteList == null)
      this.isInFavoriteList = false;
    else
      this.isInFavoriteList = isInFavoriteList;
  }

  Map<String, String> toMap() {
    return {
      'word': word,
      'definition': (definition == null || definition == "") ? "NA" : definition
    };
  }

  static SingleWord fromMap(Map<String, dynamic> wordMap, bool isInFavoriteList) {
    return SingleWord(word: wordMap['word'],
        definition: wordMap['definition'].toString(),
        isInFavoriteList: isInFavoriteList);
  }

}

class WordLibrary {
  List<SingleWord> _words;

  static final _dbTableName = "user_library";

  WordLibrary() {
    _words = List();
  }

  bool contains(String word) {
    try {
      _words.firstWhere((element) => element.word == word);
      return true;
    } catch (E) {
      return false;
    }
  }

  void addWord(SingleWord word) async{
    SingleWord _word = SingleWord(word: word.word, definition: word.definition, isInFavoriteList: true);
    _words.add(_word);

    // save it to the database
    await saveWordToDatabase(_word, await _database);
  }

  void removeWord(SingleWord word) async{
    _words.remove(word);

    // delete from database
    Database db = await _database;
    await db.execute(
      "DELETE FROM " + _dbTableName + " WHERE word=\"" + word.word + "\""
    );
  }

  List<SingleWord> get words => _words;

  // connect to user library database
  get _database async {
    return await openDatabase(
      join(await getDatabasesPath(), 'user_library.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE "+ _dbTableName +"(word VARCHAR PRIMARY KEY, definition TEXT)",
        );
      },
      version: 1
    );
  }

  Future<void> saveWordToDatabase(SingleWord word, Database db) async {
    await db.insert(_dbTableName,
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveToDatabase() async {
    Database db = await _database;
    _words.forEach((word) async {
      await saveWordToDatabase(word, db);
    });
  }

  Future<void> loadFromDatabase() async {
    Database db = await _database;

    // Query the table for all The Words.
    final List<Map<String, dynamic>> maps = await db.query(_dbTableName);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    _words = List();

    for (var i = 0; i < maps.length ; i ++ ){
      _words.add( SingleWord.fromMap(maps[i], true) );
    }
  }
}