import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/progress/data/local/progress_service.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

final lastReadProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return await service.getLastRead();
});

final lastReadSurahProvider = Provider<Surah?>((ref) {
  final surahListAsync = ref.watch(surahListProvider);
  final lastReadAsync = ref.watch(lastReadProvider);

  final surahList = surahListAsync.asData?.value;
  final lastReadData = lastReadAsync.asData?.value;

  if (surahList == null || lastReadData == null) return null;

  final id = lastReadData['surah_id'];

  if (id == null) return null;

  try {
    return surahList.firstWhere((s) => s.number == id);
  } catch (_) {
    return null;
  }
});