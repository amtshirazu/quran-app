import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/progress/presentation/state/progress_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

class ProfileProgressState {
  final double progress;
  final int streak;
  final int verses;
  final int surahs;

  ProfileProgressState({
    required this.progress,
    required this.streak,
    required this.verses,
    required this.surahs,
  });
}

final profileProgressProvider = FutureProvider<ProfileProgressState>((
  ref,
) async {
  try {
    final service = ref.read(progressServiceProvider);
    final surahs = await ref.watch(surahListProvider.future);

    final progress = await service.getQuranProgress();
    final streak = await service.getCurrentStreak();
    final verses = await service.getTotalVersesRead();
    final completedSurahs = await service.getSurahsCompleted(surahs);

    return ProfileProgressState(
      progress: (progress) * 100,
      streak: streak ?? 0,
      verses: verses,
      surahs: completedSurahs ?? 0,
    );
  } catch (_) {
    return ProfileProgressState(progress: 0, streak: 0, verses: 0, surahs: 0);
  }
});

// Static providers (these are fine as-is)
final profileNameProvider = Provider<String>((ref) => 'Abdullah');

final profileSinceProvider = Provider<String>(
  (ref) => 'Reading since Jan 2026',
);

final motivationTitleProvider = Provider<String>((ref) => 'Keep Going!');

final motivationSubtitleProvider = Provider<String>(
  (ref) => "You're doing amazing. Continue your journey with the Quran.",
);
