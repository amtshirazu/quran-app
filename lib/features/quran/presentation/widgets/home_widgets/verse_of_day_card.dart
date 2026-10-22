import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/quran/presentation/state/daily_verse_provider.dart';
import 'package:quran_app/features/settings/presentation/state/display_settings_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';

class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyVerseAsync = ref.watch(dailyVerseWithTranslationProvider);

    final quranScript = ref.watch(quranScriptProvider);
    final ayahTextSize = ref.watch(ayahTextSizeProvider);
    final translationTextSize = ref.watch(translationTextSizeProvider);
    final referenceTextSize = ref.watch(referenceTextSizeProvider);

    final fontName = quranScript == 'IndoPak' ? "Indo Park" : "Uthmanic";

    return Card(
      margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
      elevation: isDark ? 0 : 6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppTheme.darkBorder)
            : BorderSide.none,
      ),
      color: isDark ? AppTheme.darkSurface : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : null,
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [AppColors.deepGreen, AppColors.emerald600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: dailyVerseAsync.when(
            data: (verse) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.heart,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Verse of the Day",
                      style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontSize: AppSpacing.size15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  verse.arabicText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontName,
                    fontSize: ayahTextSize,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  verse.translation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: translationTextSize,
                    color: AppColors.emerald100,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Surah ${verse.surah?.nameEnglish ?? ''} (${verse.surah?.number ?? ''} : ${verse.ayahNumber})",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: referenceTextSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Error loading verse: $err",
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
