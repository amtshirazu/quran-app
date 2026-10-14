import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class QuranAudioInfoCard extends StatelessWidget {
  const QuranAudioInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      elevation: isDark ? 0 : 2,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? const BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.emerald600.withAlpha(38)
                    : AppColors.emerald100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                color: AppColors.emerald600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About Quran Audio",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSpacing.size14,
                      color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "High-quality Quranic recitations from esteemed reciters worldwide. Features both full Surah playback and verse-by-verse recitation, powered by EveryAyah and MP3Quran repositories.",
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? AppTheme.darkTextSecondary : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
