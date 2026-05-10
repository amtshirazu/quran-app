import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../state/quran_providers.dart';

class SurahInfo extends ConsumerWidget {
  const SurahInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahMetadata = ref.watch(selectedSurahProvider);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.size16),
      ),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
                fontSize: AppSpacing.size22,
                color: Colors.white,
                fontFamily: "Uthmanic",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              surahMetadata?.nameEnglish ?? "",
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.gray400,
                fontSize: AppSpacing.size16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              surahMetadata?.translation ?? "",
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.gray400,
                fontSize: AppSpacing.size14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${surahMetadata?.totalAyahs} Verses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSpacing.size14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 4),
                Text('•', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 4),
                Text(
                  surahMetadata?.revelationType ?? "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSpacing.size14,
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
