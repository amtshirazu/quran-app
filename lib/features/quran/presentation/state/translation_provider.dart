import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/quran/presentation/state/translation_service.dart';
import 'package:quran_app/features/settings/domain/model/translation_model.dart';

class VerseTranslationData {
  final String dbFileName;
  final String translationName;
  final String language;
  final String text;
  final bool isDefault;

  VerseTranslationData({
    required this.dbFileName,
    required this.translationName,
    required this.language,
    required this.text,
    required this.isDefault,
  });
}

class SelectedTranslationsNotifier extends StateNotifier<List<String>> {
  SelectedTranslationsNotifier() : super(['sahih-international.db']) {
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    try {
      final raw = await DatabaseHelper.instance.getSetting(
        'selected_translations',
      );
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        final list = decoded.cast<String>();
        if (!list.contains('sahih-international.db')) {
          list.insert(0, 'sahih-international.db');
        }
        state = list;
      }
    } catch (_) {}
  }

  Future<void> toggleTranslation(String dbFileName) async {
    if (dbFileName == 'sahih-international.db') return;

    List<String> current = List<String>.from(state);

    if (current.contains(dbFileName)) {
      current.remove(dbFileName);
    } else {
      if (current.length >= 2) {
        // Replace secondary translation
        current = ['sahih-international.db', dbFileName];
      } else {
        current.add(dbFileName);
      }
    }

    if (!current.contains('sahih-international.db')) {
      current.insert(0, 'sahih-international.db');
    }
    state = current;

    await DatabaseHelper.instance.setSetting(
      'selected_translations',
      jsonEncode(state),
    );
  }
}

final selectedTranslationsProvider =
    StateNotifierProvider<SelectedTranslationsNotifier, List<String>>((ref) {
      return SelectedTranslationsNotifier();
    });

final translationServiceProvider = Provider<TranslationDatabaseService>((ref) {
  return TranslationDatabaseService();
});

final translationProvider =
    FutureProvider.family<String, ({int surah, int verse})>((ref, arg) async {
      final service = ref.watch(translationServiceProvider);
      return service.getTranslation(arg.surah, arg.verse);
    });

final activeVerseTranslationsProvider =
    FutureProvider.family<List<VerseTranslationData>, ({int surah, int verse})>(
      (ref, arg) async {
        final activeDbNames = ref.watch(selectedTranslationsProvider);
        final service = ref.watch(translationServiceProvider);

        List<VerseTranslationData> results = [];

        for (final dbName in activeDbNames) {
          final model = kAllTranslations.firstWhere(
            (m) => m.dbFileName == dbName,
            orElse: () => kAllTranslations.first,
          );

          final text = await service.getTranslationFromDb(
            fileName: dbName,
            surah: arg.surah,
            verse: arg.verse,
          );

          results.add(
            VerseTranslationData(
              dbFileName: dbName,
              translationName: model.name,
              language: model.language,
              text: text,
              isDefault: model.isDefault,
            ),
          );
        }

        return results;
      },
    );
