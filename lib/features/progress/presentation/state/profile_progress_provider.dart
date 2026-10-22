import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/progress/domain/models/profile_progress_state.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/progress/presentation/state/progress_service.dart';
import 'package:quran_app/features/quran/domain/models/continueReadingData.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

final profileProgressProvider = FutureProvider<ProfileProgressState>((
  ref,
) async {
  try {
    final service = ref.watch(progressServiceProvider);
    final surahs = await ref.watch(surahListProvider.future);

    final progress = await service.getQuranProgress();
    final streak = await service.getCurrentStreak();
    final verses = await service.getTotalVersesRead();
    final completedSurahs = await service.getSurahsCompleted(surahs);

    return ProfileProgressState(
      progress: progress * 100,
      streak: streak ?? 0,
      verses: verses,
      surahs: completedSurahs ?? 0,
    );
  } catch (_) {
    return ProfileProgressState(progress: 0, streak: 0, verses: 0, surahs: 0);
  }
});

final profileNameProvider = Provider<String>((ref) => 'Abdullah');

final profileSinceProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(progressServiceProvider);
  final installDate = await service.getOrInitAppInstallDate();

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return 'Started on ${months[installDate.month - 1]} ${installDate.day}, ${installDate.year}';
});

final motivationTitleProvider = Provider<String>((ref) => 'Keep Going!');

final motivationSubtitleProvider = Provider<String>(
  (ref) => "You're doing amazing. Continue your journey with the Quran.",
);

final continueReadingProvider = FutureProvider<ContinueReadingData?>((
  ref,
) async {
  final lastRead = await ref.watch(lastReadProvider.future);
  if (lastRead == null) return null;

  final resolvedSurah = await ref.watch(lastReadResolvedSurahProvider.future);
  if (resolvedSurah == null) return null;

  final service = ref.watch(progressServiceProvider);
  final mode = (lastRead['mode'] as String?) ?? 'ayah';

  // Calculate live progress directly without stale family provider caches
  final progress =
      await service.getSurahProgress(
        surahId: resolvedSurah.number,
        totalAyahs: resolvedSurah.totalAyahs,
      ) ??
      0.0;

  final displayText = mode == 'ayah'
      ? "Verse ${lastRead['ayah']}"
      : "Page ${lastRead['page']}";

  return ContinueReadingData(
    surah: resolvedSurah,
    displayText: displayText,
    progress: progress,
  );
});
