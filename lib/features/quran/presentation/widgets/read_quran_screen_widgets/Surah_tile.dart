import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/surah_verse_number_badge.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/surah_verses_badge.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../domain/models/surah.dart';

class SurahTile extends ConsumerWidget {
  const SurahTile({super.key, required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final progressService = ref.read(progressServiceProvider);
          await progressService.clearLastRead();
          ref.invalidate(lastReadProvider);
          ref.invalidate(lastReadResolvedSurahProvider);
          ref.invalidate(profileProgressProvider);
          ref.invalidate(continueReadingProvider);
          ref.read(searchQueryProvider.notifier).state = "";
          ref.read(selectedSurahProvider.notifier).state = surah;
          ref.read(shouldResumeLastReadProvider.notifier).state = false;
          context.push("/readAyah");
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                width: 0.8,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SurahVerseNumberBadge(surahNumber: surah.number),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      surah.nameEnglish,
                      style: textTheme.titleMedium?.copyWith(
                        color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                        fontSize: AppSpacing.size13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      surah.translation,
                      style: textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
                        fontSize: AppSpacing.size10,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    surah.nameArabic,
                    style: textTheme.titleMedium?.copyWith(
                      color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                      fontSize: AppSpacing.size14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SurahVersesBadge(totalAyahs: surah.totalAyahs),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronRight,
                        color: isDark ? AppTheme.darkTextSecondary : AppColors.gray400,
                        size: AppSpacing.size16,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
