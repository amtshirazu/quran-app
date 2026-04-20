import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/progress/data/local/progress_service.dart';



final profileNameProvider = Provider<String>((ref) => 'Abdullah');
final profileSinceProvider = Provider<String>((ref) => 'Reading since Jan 2026');

final quranCompletionProvider = Provider<double>((ref) => 23.0);

final streakProvider = FutureProvider<int>((ref) async {
  final service = ref.read(progressServiceProvider);
  return await service.getCurrentStreak();
});

final versesReadProvider = FutureProvider<int>((ref) async {
  final service = ref.read(progressServiceProvider);
  return service.getTotalVersesRead();
});

final surahsReadProvider = FutureProvider<int>((ref) async {
  final service = ref.read(progressServiceProvider);
  final surahs = await ref.watch(surahListProvider.future);

  return service.getSurahsRead(surahs);
});

final motivationTitleProvider = Provider<String>((ref) => 'Keep Going!');
final motivationSubtitleProvider = Provider<String>((ref) =>
    "You're doing amazing. Continue your journey with the Quran.");
