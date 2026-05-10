import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/presentation/state/translation_service.dart';

final translationServiceProvider = Provider<TranslationDatabaseService>((ref) {
  return TranslationDatabaseService(dbFileName: 'pickthall.db');
});

final translationProvider =
    FutureProvider.family<String, ({int surah, int verse})>((ref, arg) async {
      final service = ref.watch(translationServiceProvider);
      return service.getTranslation(arg.surah, arg.verse);
    });
