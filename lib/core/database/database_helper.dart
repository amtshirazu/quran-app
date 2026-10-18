import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _databaseVersion = 1;
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

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Runs ONLY on fresh installs when quran.db does not exist yet
  Future<void> _createDB(Database db, int version) async {
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
      id INTEGER PRIMARY KEY AUTOINCREMENT,
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
      surah_id INTEGER,
      ayah_number INTEGER,
      page INTEGER,
      note TEXT,
      type TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE reflections (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      surah_id INTEGER NOT NULL,
      ayah_number INTEGER NOT NULL,
      content TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE recent_searches (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      query TEXT UNIQUE,
      timestamp INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE user_settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
    ''');
  }

  // Runs sequentially whenever _databaseVersion is incremented
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      switch (version) {
        // Example future update:
        // case 2:
        //   await db.execute('ALTER TABLE bookmarks ADD COLUMN category_id INTEGER DEFAULT 0;');
        //   break;
        default:
          throw StateError(
            'Missing database migration for version $version. '
            'Refusing to open an unsupported schema.',
          );
      }
    }
  }

  // Settings helper methods
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('user_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }
}
