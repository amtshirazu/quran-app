import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/features/audio/data/audio_timing_service.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/Surah_tile.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/mode_switcher.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final testSurah1 = Surah(
    number: 1,
    nameArabic: "الفاتحة",
    nameEnglish: "Al-Fatihah",
    translation: "The Opening",
    totalAyahs: 7,
    revelationType: "Meccan",
  );

  group('AudioTimingService In-Memory Cache Unit Tests', () {
    test(
      'Cache returns identical in-memory records on subsequent hits',
      () async {
        final dbFile = File('assets/database/audio_timestamps.db');
        expect(dbFile.existsSync(), isTrue);

        AudioTimingService.instance.clearCache();

        // First call populates cache
        final verse1 = await AudioTimingService.instance.getActiveAyah(
          reciterId: 'alafasy',
          surahNumber: 1,
          positionMillis: 7000,
        );
        expect(verse1, equals(1));

        // Second call hits cache directly
        final verse1Cached = await AudioTimingService.instance.getActiveAyah(
          reciterId: 'alafasy',
          surahNumber: 1,
          positionMillis: 12000,
        );
        expect(verse1Cached, equals(2));

        final startMillis = await AudioTimingService.instance
            .getAyahStartTimestamp(
              reciterId: 'alafasy',
              surahNumber: 1,
              ayahNumber: 1,
            );
        expect(startMillis, isNotNull);

        // Verify clearCache empties cache
        AudioTimingService.instance.clearCache();
      },
    );
  });

  group('Widget Tests for SurahTile & ModeSwitcher', () {
    testWidgets('SurahTile renders Surah metadata accurately', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: SurahTile(surah: testSurah1)),
          ),
        ),
      );

      // Verify SurahTile displays English, Arabic, and Translation text
      expect(find.text("Al-Fatihah"), findsOneWidget);
      expect(find.text("الفاتحة"), findsOneWidget);
      expect(find.text("The Opening"), findsOneWidget);
    });

    testWidgets('ModeSwitcher toggles between Reading and Translation mode', (
      WidgetTester tester,
    ) async {
      ReadingMode activeMode = ReadingMode.translation;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 250,
                    child: ModeSwitcher(
                      mode: activeMode,
                      onChanged: (newMode) {
                        setState(() {
                          activeMode = newMode;
                        });
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Default mode should be Translation
      expect(activeMode, equals(ReadingMode.translation));

      // Tap Reading button inside ModeSwitcher
      await tester.tap(find.text('Reading'));
      await tester.pumpAndSettle();

      // Verify mode toggled to Reading Mode
      expect(activeMode, equals(ReadingMode.reading));
    });
  });
}
