import 'dart:math';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/dua_service.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/translation_service.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/model/recent_search.dart';
import '../domain/model/search_result.dart';

class SearchService {
  final TranslationDatabaseService translationService;
  final DuaDatabaseService duaService;
  final MuslimRepository muslimRepo;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  SearchService({
    required this.translationService,
    required this.duaService,
    required this.muslimRepo,
  });

  /// Ensures recent_searches table exists before any database query
  Future<void> _ensureRecentSearchesTableExists(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recent_searches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT UNIQUE,
        timestamp INTEGER
      )
    ''');
  }

  /// 20 static high-frequency queries
  static const List<String> _kPopularSearchPool = [
    "Ayat al-Kursi",
    "Surah Al-Kahf",
    "Surah Ya-sin",
    "Surah Al-Mulk",
    "Surah Ar-Rahman",
    "Surah Al-Waqi'ah",
    "Patience (Sabr)",
    "Forgiveness (Istighfar)",
    "Morning Adhkar",
    "Evening Adhkar",
    "Rabbana Duas",
    "Tawakkul",
    "Gratitude (Shukr)",
    "Tahajjud Prayer",
    "Protection from Evil Eye",
    "Anxiety & Relief",
    "Parents in Quran",
    "Repentance",
    "Prophet Musa",
    "Day of Judgment",
  ];

  /// Selects count items deterministically based on today's date (YYYYMMDD) seed
  List<String> getDailyPopularSearches({int count = 10}) {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final List<String> poolCopy = List.from(_kPopularSearchPool);
    poolCopy.shuffle(random);
    return poolCopy.take(count).toList();
  }

  /// Primary Execution Method: Unified Multi-Source Parallel Search
  Future<UnifiedSearchResults> searchAll({
    required String query,
    required List<Surah> allSurahs,
  }) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.length < 2) {
      return UnifiedSearchResults(
        query: query,
        ayahs: [],
        surahs: [],
        azkaar: [],
        duas: [],
      );
    }

    final results = await Future.wait([
      searchAyahs(trimmed),
      Future.value(searchSurahs(trimmed, allSurahs)),
      searchAzkaar(trimmed),
      searchDuas(trimmed),
    ]);

    return UnifiedSearchResults(
      query: query,
      ayahs: results[0] as List<AyahSearchResult>,
      surahs: results[1] as List<Surah>,
      azkaar: results[2] as List<AzkarSearchResult>,
      duas: results[3] as List<QuranicDua>,
    );
  }

  /// Helper: Search Ayahs in Pickthall Translation Database
  Future<List<AyahSearchResult>> searchAyahs(String trimmedQuery) async {
    final List<AyahSearchResult> ayahs = [];
    try {
      final db = await translationService.database;
      final List<Map<String, dynamic>> rows = await db.query(
        'translation',
        where: 'text LIKE ?',
        whereArgs: ['%$trimmedQuery%'],
        limit: 100,
      );

      for (final row in rows) {
        final sura = row['sura'] as int;
        final ayah = row['ayah'] as int;
        final text = row['text'] as String;
        final surahName = quran.getSurahName(sura);
        final arabicText = quran.getVerse(sura, ayah, verseEndSymbol: false);

        ayahs.add(
          AyahSearchResult(
            surahNum: sura,
            ayahNum: ayah,
            surahName: surahName,
            arabicText: arabicText,
            translationText: text,
          ),
        );
      }
    } catch (_) {
      // Gracefully handle errors and return empty list on failure
    }
    return ayahs;
  }

  /// Helper: Search Surahs by English Name, Arabic Name, or Translation
  List<Surah> searchSurahs(String trimmedQuery, List<Surah> allSurahs) {
    try {
      return allSurahs.where((s) {
        return s.nameEnglish.toLowerCase().contains(trimmedQuery) ||
            s.nameArabic.contains(trimmedQuery) ||
            s.translation.toLowerCase().contains(trimmedQuery) ||
            'surah ${s.nameEnglish.toLowerCase()}'.contains(trimmedQuery);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Helper: Search Azkaar Categories & Chapters
  Future<List<AzkarSearchResult>> searchAzkaar(String trimmedQuery) async {
    final List<AzkarSearchResult> azkaar = [];
    try {
      final categories = await muslimRepo.getAzkarCategories(
        language: Language.en,
      );
      for (final cat in categories) {
        final chapters = await muslimRepo.getAzkarChapters(
          language: Language.en,
          categoryId: cat.id,
        );
        for (final chap in chapters) {
          if (chap.name.toLowerCase().contains(trimmedQuery) ||
              cat.name.toLowerCase().contains(trimmedQuery)) {
            azkaar.add(AzkarSearchResult(category: cat, chapter: chap));
          }
        }
      }
    } catch (_) {
      // Gracefully handle errors
    }
    return azkaar;
  }

  /// Helper: Search Duas across Quranic and Witr databases
  Future<List<QuranicDua>> searchDuas(String trimmedQuery) async {
    final List<QuranicDua> duas = [];
    try {
      final quranicDuas = await duaService.searchDuasByCategory(
        DuaCategory.quranic,
        trimmedQuery,
      );
      final witrDuas = await duaService.searchDuasByCategory(
        DuaCategory.witr,
        trimmedQuery,
      );
      duas.addAll(quranicDuas);
      duas.addAll(witrDuas);
    } catch (_) {
      // Gracefully handle errors
    }
    return duas;
  }

  /// Fetch recent searches ordered by timestamp DESC
  Future<List<RecentSearch>> getRecentSearches({int limit = 10}) async {
    try {
      final db = await _databaseHelper.database;
      await _ensureRecentSearchesTableExists(db);

      final maps = await db.rawQuery('''
        SELECT query, MAX(timestamp) as timestamp
        FROM recent_searches
        GROUP BY query
        ORDER BY timestamp DESC
        LIMIT ?
      ''', [limit]);

      return maps.map((map) => RecentSearch.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Insert or replace a recent search query
  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;

    try {
      final db = await _databaseHelper.database;
      await _ensureRecentSearchesTableExists(db);

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await db.delete(
        'recent_searches',
        where: 'query = ?',
        whereArgs: [trimmed],
      );

      await db.insert(
        'recent_searches',
        {
          'query': trimmed,
          'timestamp': timestamp,
        },
      );
    } catch (e) {
      // Handle error gracefully
    }
  }

  /// Delete a recent search entry by query
  Future<void> deleteRecentSearch(String query) async {
    try {
      final db = await _databaseHelper.database;
      await _ensureRecentSearchesTableExists(db);

      await db.delete(
        'recent_searches',
        where: 'query = ?',
        whereArgs: [query],
      );
    } catch (_) {}
  }

  /// Clear all recent searches
  Future<void> clearAllRecentSearches() async {
    try {
      final db = await _databaseHelper.database;
      await _ensureRecentSearchesTableExists(db);

      await db.delete('recent_searches');
    } catch (_) {}
  }
}
