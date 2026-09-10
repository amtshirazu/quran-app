import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/quran/presentation/state/tafseer_service.dart';
import 'package:quran_app/features/settings/domain/model/tafseer_model.dart';

class SelectedTafseerNotifier extends StateNotifier<String> {
  SelectedTafseerNotifier() : super('en_tafisr-ibn-kathir.db') {
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    try {
      final raw = await DatabaseHelper.instance.getSetting('selected_tafseer');
      if (raw != null && raw.isNotEmpty) {
        state = raw;
      }
    } catch (_) {}
  }

  Future<void> setTafseer(String dbFileName) async {
    state = dbFileName;
    await DatabaseHelper.instance.setSetting('selected_tafseer', dbFileName);
  }
}

final selectedTafseerProvider =
    StateNotifierProvider<SelectedTafseerNotifier, String>((ref) {
  return SelectedTafseerNotifier();
});

final tafseerServiceProvider = Provider<TafseerDatabaseService>((ref) {
  return TafseerDatabaseService();
});

/// Provider fetching Tafseer content for a specific surah and verse
final verseTafseerProvider = FutureProvider.family<
    ({TafseerModel model, String content}),
    ({int surah, int verse})>((ref, arg) async {
  final selectedDbName = ref.watch(selectedTafseerProvider);
  final service = ref.watch(tafseerServiceProvider);

  final model = kAllTafseers.firstWhere(
    (m) => m.dbFileName == selectedDbName,
    orElse: () => kAllTafseers.first,
  );

  final content = await service.getTafseerFromDb(
    fileName: selectedDbName,
    surah: arg.surah,
    verse: arg.verse,
  );

  return (model: model, content: content);
});
