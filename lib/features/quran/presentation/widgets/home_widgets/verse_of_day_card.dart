import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/quran/presentation/state/daily_verse_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';

class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final dailyVerseAsync = ref.watch(dailyVerseWithTranslationProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.emerald500, AppColors.emerald600],
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
                        fontSize: AppSpacing.size16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  verse.arabicText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "Uthmanic",
                    fontSize: AppSpacing.size24,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  verse.translation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppSpacing.size14,
                    color: AppColors.emerald50,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                // Surah MetaData
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Surah ${verse.surah?.nameEnglish ?? ''} (${verse.surah?.number ?? ''} : ${verse.ayahNumber})",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppSpacing.size12,
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
