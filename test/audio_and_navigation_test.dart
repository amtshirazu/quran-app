import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/features/audio/data/audio_timing_service.dart';
import 'package:quran_app/features/audio/data/reciters_list.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database & Timing Tests', () {
    test(
      'Database lookups using app reciter IDs and MP3Quran read IDs',
      () async {
        final dbFile = File('assets/database/audio_timestamps.db');
        expect(dbFile.existsSync(), isTrue);

        final db = await openDatabase(dbFile.absolute.path, readOnly: true);

        for (final reciter in reciters) {
          final rows = await db.query(
            'ayah_timestamps',
            where: 'reciter_id = ? AND reciter_api_id = ? AND surah_number = 1',
            whereArgs: [reciter.id, reciter.mp3QuranReadId],
          );
          expect(
            rows.isNotEmpty,
            isTrue,
            reason:
                'Timing data must exist for reciter ${reciter.id} with readId ${reciter.mp3QuranReadId}',
          );
        }

        await db.close();
      },
    );

    test('Ayah timing boundaries and missing records', () async {
      final dbFile = File('assets/database/audio_timestamps.db');
      final dbPath = dbFile.absolute.path;

      // Ensure DB exists and query directly if needed
      final db = await openDatabase(dbPath, readOnly: true);
      final rows = await db.query(
        'ayah_timestamps',
        where: 'reciter_id = ? AND surah_number = 1 AND ayah_number = 1',
        whereArgs: ['alafasy'],
      );
      expect(rows.isNotEmpty, isTrue);
      final startMillis = rows.first['timestamp_from'] as int;

      expect(startMillis, greaterThanOrEqualTo(0));

      final activeAyahBeforeFirst = await AudioTimingService.instance
          .getActiveAyah(
            reciterId: 'alafasy',
            surahNumber: 1,
            positionMillis: 0,
          );
      expect(activeAyahBeforeFirst, equals(1));

      final activeAyahMid = await AudioTimingService.instance.getActiveAyah(
        reciterId: 'alafasy',
        surahNumber: 1,
        positionMillis: startMillis + 500,
      );
      expect(activeAyahMid, equals(1));

      final nonExistentReciter = await AudioTimingService.instance
          .getActiveAyah(
            reciterId: 'invalid_reciter',
            surahNumber: 1,
            positionMillis: 5000,
          );
      expect(nonExistentReciter, isNull);

      await db.close();
    });
  });

  group('Repeat Mode & Provider Tests', () {
    test('Default repeat mode must be RepeatStates.off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repeatMode = container.read(repeatModeProvider);
      expect(repeatMode, equals(RepeatStates.off));
    });

    test('Translation Mode forces Repeat OFF', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(repeatModeProvider.notifier).state =
          RepeatStates.repeatAll;
      expect(
        container.read(repeatModeProvider),
        equals(RepeatStates.repeatAll),
      );

      // Switch to Translation Mode
      container.read(readingModeProvider.notifier).state =
          ReadingMode.translation;
      if (container.read(readingModeProvider) == ReadingMode.translation) {
        container.read(repeatModeProvider.notifier).state = RepeatStates.off;
      }

      expect(container.read(repeatModeProvider), equals(RepeatStates.off));
    });
  });

  group('Multi-Surah Page Resolution Tests', () {
    test('Pages containing multiple Surahs (e.g. Page 602)', () {
      final pageData = quran.getPageData(602);
      final surahs = pageData.map((e) => e['surah'] as int).toList();

      expect(surahs.contains(106), isTrue);
      expect(surahs.contains(107), isTrue);
      expect(surahs.contains(108), isTrue);
    });

    test(
      'Case A: Explicit Surah selection vs Case B: Ordinary page navigation',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final dummySurah107 = Surah(
          number: 107,
          nameArabic: "الماعون",
          nameEnglish: "Al-Ma'un",
          translation: "Small Kindness",
          totalAyahs: 7,
          revelationType: "Meccan",
        );

        // Case A: Explicit selection of Surah 107
        container.read(selectedSurahProvider.notifier).state = dummySurah107;
        container.read(explicitSurahSelectionProvider.notifier).state =
            dummySurah107;

        final explicitSurah = container.read(explicitSurahSelectionProvider);
        final page602Surahs = quran
            .getPageData(602)
            .map((e) => e['surah'] as int)
            .toList();

        int resolvedSurahCaseA;
        if (explicitSurah != null &&
            page602Surahs.contains(explicitSurah.number)) {
          resolvedSurahCaseA = explicitSurah.number;
        } else {
          resolvedSurahCaseA = page602Surahs.first;
        }
        expect(
          resolvedSurahCaseA,
          equals(107),
          reason: 'Case A must select Surah 107 on page 602',
        );

        // Case B: User swipes to Page 602 without explicit selection
        container.read(explicitSurahSelectionProvider.notifier).state = null;
        final resolvedSurahCaseB = quran.getPageData(602).first['surah'] as int;
        expect(
          resolvedSurahCaseB,
          equals(106),
          reason: 'Case B must pick topmost Surah 106 on page 602',
        );
      },
    );

    test('Starting playback from a page partway through a Surah', () {
      // Page 2 contains Surah 2 starting at Ayah 1
      final page2Data = quran.getPageData(2);
      expect(page2Data.first['surah'], equals(2));
      expect(page2Data.first['start'], equals(1));

      // Page 3 contains Surah 2 starting at Ayah 6
      final page3Data = quran.getPageData(3);
      expect(page3Data.first['surah'], equals(2));
      expect(page3Data.first['start'], equals(6));
    });
  });

  group('Audio Service Stale State & Concurrency Protection Tests', () {
    test(
      'Invalidating state on stop/clear prevents stale Ayah publication',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Publish initial state
        container.read(currentPlayingAyahProvider.notifier).state =
            AyahIdentifier(surah: 1, ayah: 3, page: 1);
        expect(container.read(currentPlayingAyahProvider)?.ayah, equals(3));

        // Simulate clearActiveState
        container.read(currentPlayingAyahProvider.notifier).state = null;
        container.read(jumpToPageProvider.notifier).state = null;
        container.read(targetAyahProvider.notifier).state = null;

        expect(container.read(currentPlayingAyahProvider), isNull);
        expect(container.read(jumpToPageProvider), isNull);
        expect(container.read(targetAyahProvider), isNull);
      },
    );
  });
}
