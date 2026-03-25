import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/quran/presentation/state/daily_verse_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../state/quran_providers.dart';




class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final textTheme = Theme.of(context).textTheme;
    final ayahAsync = ref.watch(dailyVerseWithTranslationProvider);


    return Card(
      margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.emerald500,
              AppColors.emerald600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ayahAsync.when(
            data: (ayahWithTranslation) => Column(
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ayahWithTranslation.ayah.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: AppSpacing.size18,
                      color: Colors.white
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  ayahWithTranslation.translation.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: AppSpacing.size12,
                      color: AppColors.emerald50
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Surah ${ayahWithTranslation.surah?.nameEnglish} (${ayahWithTranslation.ayah.surahNumber} : ${ayahWithTranslation.ayah.ayahNumber})",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppSpacing.size14,
                    color: AppColors.emerald50,
                  ),
                ),
              ],
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (err, stack) => Text(
              "Error loading verse: $err",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}