import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../progress/presentation/state/progress_provider.dart';
import '../../state/reading_mode.dart';
import 'empty_card.dart';

class ContinueReadingCard extends ConsumerWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadAsync = ref.watch(lastReadProvider);
    final surahListAsync = ref.watch(surahListProvider);

    return lastReadAsync.when(
      data: (lastRead) {
        if (lastRead == null || lastRead['surah_id'] == null) {
          return const EmptyCard();
        }

        return surahListAsync.when(
          data: (surahList) {
            final surah = surahList.firstWhere(
              (s) => s.number == lastRead['surah_id'],
            );

            return FutureBuilder<double>(
              future: ref
                  .read(progressServiceProvider)
                  .getSurahProgress(
                    surahId: surah.number,
                    totalAyahs: surah.totalAyahs,
                  )
                  .then((value) => value ?? 0.0),
              builder: (context, snapshot) {
                final progress = snapshot.data ?? 0.0;
                final mode = lastRead['mode'];
                final displayVal = mode == 'ayah'
                    ? "Verse ${lastRead['ayah']}"
                    : "Page ${lastRead['page']}";

                return InkWell(
                  onTap: () {
                    ref.read(selectedSurahProvider.notifier).state = surah;
                    if (mode == 'page') {
                      ref.read(readingModeProvider.notifier).state =
                          ReadingMode.reading;
                    } else {
                      ref.read(readingModeProvider.notifier).state =
                          ReadingMode.translation;
                    }
                    context.go('/readAyah');
                  },
                  child: _buildCard(
                    subtitle: "${surah.nameEnglish} • $displayVal",
                    progress: progress,
                  ),
                );
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const EmptyCard(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyCard(),
    );
  }
}

Widget _buildCard({required String subtitle, required double progress}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
    color: Colors.white,
    elevation: 6,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.bookOpen,
                color: AppColors.emerald600,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "Continue Reading",
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: AppSpacing.size16,
                ),
              ),
              const Spacer(),
              const Icon(
                LucideIcons.chevronRight,
                color: AppColors.gray600,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: AppSpacing.size12,
            ),
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.gray200,
            valueColor: const AlwaysStoppedAnimation(AppColors.emerald600),
          ),

          const SizedBox(height: 8),

          Text(
            "${(progress * 100).toStringAsFixed(0)}% completed",
            style: const TextStyle(
              fontSize: AppSpacing.size12,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    ),
  );
}
