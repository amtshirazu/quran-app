import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import '../../../../progress/presentation/state/last_read_provider.dart';
import '../../state/reading_mode.dart';
import 'empty_card.dart';

class ContinueReadingCard extends ConsumerWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueReadingAsync = ref.watch(continueReadingProvider);

    return continueReadingAsync.when(
      data: (data) {
        if (data == null) {
          return const EmptyCard();
        }
        return InkWell(
          onTap: () async {
            ref.read(selectedSurahProvider.notifier).state = data.surah;
            ref.read(shouldResumeLastReadProvider.notifier).state = true;

            final lastRead = ref.read(lastReadProvider).asData?.value;
            final mode = lastRead?['mode'];

            ref.read(readingModeProvider.notifier).state = mode == 'page'
                ? ReadingMode.reading
                : ReadingMode.translation;

            context.go('/readAyah');
          },
          child: _buildCard(
            context,
            subtitle: "${data.surah.nameEnglish} • ${data.displayText}",
            progress: data.progress,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const EmptyCard(),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String subtitle,
    required double progress,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      color: isDark ? AppTheme.darkSurface : Colors.white,
      elevation: isDark ? 0 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? const BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.bookOpen,
                  color: AppColors.emerald600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Continue Reading",
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  LucideIcons.chevronRight,
                  color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppTheme.darkBorder : AppColors.gray200,
              valueColor: const AlwaysStoppedAnimation(AppColors.emerald600),
            ),
            const SizedBox(height: 6),
            Text(
              "${(progress * 100).toStringAsFixed(0)}% completed",
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
