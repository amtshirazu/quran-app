import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/data/datasource/surah_local_datasource.dart';
import 'package:quran_app/features/quran/data/repository/quran_metadata.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import '../../domain/models/surah.dart';

final shouldResumeLastReadProvider = StateProvider<bool>((ref) => false);

final jumpToPageProvider = StateProvider<int?>((ref) => null);

final targetAyahProvider = StateProvider<int?>((ref) => null);

final isAutoScrollingProvider = StateProvider<bool>((ref) => false);

final surahRepositoryProvider = Provider<SurahMetadataRepository>((ref) {
  return SurahMetadataRepository(surahs: SurahLocalDatasource());
});

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(surahRepositoryProvider);
  final stopwatch = Stopwatch()..start();

  try {
    final data = await repo.getSurahMetadata();
    stopwatch.stop();
    debugPrint(
      "⚡ SURAH METADATA LOADED: ${data.length} surahs in ${stopwatch.elapsedMilliseconds}ms",
    );
    return data;
  } catch (e, st) {
    debugPrint("❌ ERROR loading surahs: $e\n$st");
    rethrow;
  }
});

final readingModeProvider = StateProvider<ReadingMode>((ref) {
  return ReadingMode.translation;
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSurahProvider = StateProvider<Surah?>((ref) => null);

/// Tracks explicit user selection of a Surah (e.g. tapping a Surah in the list),
/// distinguishing it from ordinary page swipes across multi-Surah pages.
final explicitSurahSelectionProvider = StateProvider<Surah?>((ref) => null);

final currentPlayingAyahProvider = StateProvider<AyahIdentifier?>(
  (ref) => null,
);

class AyahIdentifier {
  final int surah;
  final int ayah;
  final int page;
  AyahIdentifier({required this.surah, required this.ayah, required this.page});
}

final currentPlayingPageProvider = Provider<int?>((ref) {
  final playing = ref.watch(currentPlayingAyahProvider);
  return playing?.page;
});

//used to determine the bookmark state of the current page
final currentPageProvider = StateProvider<int?>((ref) => 0);

//surah id of current page
final currentPageSurahIdProvider = StateProvider<int?>((ref) => null);

// used to display the current page's surah in the SurahHeaderSection
final currentPageSurahProvider = FutureProvider<Surah?>((ref) async {
  final activeSurahId = ref.watch(currentPageSurahIdProvider);

  if (activeSurahId == null) return null;

  final surahList = await ref.watch(surahListProvider.future);

  try {
    return surahList.firstWhere((s) => s.number == activeSurahId);
  } catch (_) {
    return null;
  }
});
