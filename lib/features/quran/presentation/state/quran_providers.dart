import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/quran/data/datasource/surah_local_datasource.dart';
import 'package:quran_app/features/quran/data/repository/quran_metadata.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import '../../domain/models/surah.dart';

final shouldResumeLastReadProvider = StateProvider<bool>((ref) => false);

final jumpToPageProvider = StateProvider<int?>((ref) => null);

final surahRepositoryProvider = Provider<SurahMetadataRepository>((ref) {
  return SurahMetadataRepository(surahs: SurahLocalDatasource());
});

final surahListProvider = FutureProvider((ref) async {
  final repo = ref.watch(surahRepositoryProvider);

  try {
    final data = await repo.getSurahMetadata();
    print("Loaded ${data.length} surahs");
    return data;
  } catch (e, st) {
    print("ERROR loading surahs: $e");
    print(st);
    rethrow;
  }
});

final readingModeProvider = StateProvider<ReadingMode>((ref) {
  return ReadingMode.translation;
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSurahProvider = StateProvider<Surah?>((ref) => null);
final defaultReciterProvider = Provider<Reciter?>(
  (ref) => Reciter(
    id: "abu_bakr_shaatree",
    name: "Abu Bakr Ash-Shaatree",
    arabicName: "أبو بكر الشاطري",
    image: "assets/reciters/shatri.jpg",
    country: "Saudi Arabia",
    style: "Hafs - Murattal",
    totalSurahs: 114,
    audioFolder: "Abu_Bakr_Ash-Shaatree_128kbps",
    serverUrl: "https://server11.mp3quran.net/shatri",
  ),
);

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
