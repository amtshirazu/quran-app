import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';

class PlaylistCard extends ConsumerWidget {
  const PlaylistCard({
    super.key,
    required this.surahs,
  });

  final List<Surah> surahs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedSurahIndexProvider);
    final audioService = ref.read(audioServiceProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 24, top: 0),
      physics: const BouncingScrollPhysics(),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final isSelected = selectedIndex == index;

        final itemBgColor = isSelected
            ? (isDark ? AppTheme.darkBorder : AppColors.gray200)
            : (isDark ? AppTheme.darkSurface : Colors.white);

        final textColor =
        isDark ? AppTheme.darkTextPrimary : Colors.black;

        final subtextColor =
        isDark ? AppTheme.darkTextSecondary : AppColors.gray600;

        return InkWell(
          onTap: () async {
            final reciter = ref.read(selectedReciterProvider);

            if (reciter == null) {
              return;
            }

            try {
              // playSurah will set selectedSurahIndexProvider internally under a lock
              await audioService.playSurah(
                reciter: reciter,
                surah: surah,
                allSurahs: surahs,
              );
            } catch (e) {
              debugPrint('Audio error: $e');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: itemBgColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // ---------------------------------------------------------
                // SURAH NUMBER
                // ---------------------------------------------------------
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.emerald600
                        : (isDark
                        ? AppTheme.darkScaffold
                        : AppColors.gray200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${surah.number}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSpacing.size12,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ---------------------------------------------------------
                // ENGLISH NAME + TRANSLATION
                // ---------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameEnglish,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: AppSpacing.size14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.translation} • ${surah.totalAyahs} verses',
                        style: TextStyle(
                          fontSize: AppSpacing.size11,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------------------
                // ARABIC NAME
                // ---------------------------------------------------------
                Text(
                  surah.nameArabic,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Uthmanic',
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}