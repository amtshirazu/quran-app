import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quran.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE reading_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mode TEXT,
      surah_id INTEGER,
      ayah INTEGER,
      page INTEGER,
      timestamp TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE last_read (
      id INTEGER PRIMARY KEY,
      surah_id INTEGER,
      ayah INTEGER,
      page INTEGER,
      mode TEXT,
      updated_at TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE streak (
      id INTEGER PRIMARY KEY,
      last_read_date TEXT,
      current_streak INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      surah_id INTEGER NOT NULL,
      ayah_number INTEGER NOT NULL,
      page INTEGER,
      note TEXT,
      created_at TEXT NOT NULL
    )
    ''');
  }
}
