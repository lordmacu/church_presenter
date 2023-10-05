import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final directory = await getApplicationSupportDirectory();
    String path = directory.path;
    String dbPath = join(path, "ipucdba3.db");

    var theDb = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          youtubeUrl TEXT,
          paragraphs TEXT,
          lyricsPlain TEXT,
          videoExplanation TEXT,
          searchableTitle TEXT,
          searchableText TEXT)
        ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS books (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          book_id INTEGER,
          testament_id TEXT,
          name TEXT,
          abbreviation TEXT)
        ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS testaments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      testament_id INTEGER,
      name TEXT)
    ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS verses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER,
          book_id INTEGER,
          book_name TEXT,
          book_text TEXT,
          version TEXT,
          chapter INTEGER,
          verse INTEGER,
          book_chapter_verse TEXT,
          text TEXT,
          searchableText TEXT)
        ''');
  }
}
