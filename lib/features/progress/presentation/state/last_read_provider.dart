import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

// Provides last read info
final lastReadProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return await service.getLastRead();
});

// this is a derived provider that resolves the last read surah based on the last read info and the list of surahs
// used to display the last read on the, ContinueReading Card and to jump to the last read surah when the user clicks on it
// used also for displaying the last read on for the QuickAccessCard on the QuranReaderScreen
final lastReadResolvedSurahProvider = FutureProvider<Surah?>((ref) async {
  final lastRead = await ref.watch(lastReadProvider.future);
  final surahList = await ref.watch(surahListProvider.future);

  if (lastRead == null) return null;

  final mode = lastRead['mode'] as String;
  final service = ref.watch(progressServiceProvider);
  final activeSurahId = await service.resolveActiveSurah(
    mode: mode,
    surahId: lastRead['surah_id'] as int?,
    page: lastRead['page'] as int?,
  );
  if (activeSurahId == null) return null;
  return surahList.firstWhere((s) => s.number == activeSurahId);
});
