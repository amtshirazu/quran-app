import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../state/quran_providers.dart';

class SurahInfo extends ConsumerWidget {
  const SurahInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahMetadata = ref.watch(selectedSurahProvider);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.size16),
        side: isDark ? const BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      elevation: isDark ? 0 : 6,
      color: isDark ? AppTheme.darkSurface : null,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : null,
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [AppColors.emerald500, AppColors.emerald600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppSpacing.size16),
        ),
        padding: const EdgeInsets.all(AppSpacing.size20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              surahMetadata?.nameArabic ?? "",
              style: TextStyle(
                fontSize: AppSpacing.size18,
                color: isDark ? AppTheme.darkTextPrimary : Colors.white,
                fontFamily: "Uthmanic",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              surahMetadata?.nameEnglish ?? "",
              style: textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppColors.gray400,
                fontSize: AppSpacing.size14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              surahMetadata?.translation ?? "",
              style: textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppColors.gray400,
                fontSize: AppSpacing.size11,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${surahMetadata?.totalAyahs} Verses',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextPrimary : Colors.white,
                    fontSize: AppSpacing.size10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 4),
                Text('•', style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : Colors.white)),
                const SizedBox(width: 4),
                Text(
                  surahMetadata?.revelationType ?? "",
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextPrimary : Colors.white,
                    fontSize: AppSpacing.size10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
