import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';
import 'package:quran_app/features/settings/presentation/state/display_settings_provider.dart';

import '../../../../../core/constants/app_spacing.dart';

class DuaCard extends ConsumerWidget {
  final QuranicDua dua;

  const DuaCard({super.key, required this.dua});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWitr = dua.categoryType == 'witr';

    final quranScript = ref.watch(quranScriptProvider);
    final ayahTextSize = ref.watch(ayahTextSizeProvider);
    final translationTextSize = ref.watch(translationTextSizeProvider);
    final transliterationTextSize = ref.watch(transliterationTextSizeProvider);
    final referenceTextSize = ref.watch(referenceTextSizeProvider);

    final fontName = quranScript == 'IndoPak' ? "Indo Park" : "Uthmanic";

    final formattedSubject = isWitr
        ? 'Qunoot & Supplication'
        : (dua.subject.isNotEmpty
              ? '${dua.subject[0].toUpperCase()}${dua.subject.substring(1)}'
              : 'General');

    final referenceText = isWitr
        ? (dua.source ?? "Hadith / Sunnah")
        : "Quran ${dua.surahNum}:${dua.ayahNum}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedSubject,
                      style: TextStyle(
                        fontSize: AppSpacing.size13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.emerald600.withAlpha(38)
                            : AppColors.emerald100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isWitr ? "Witr & Qunoot" : "Quran",
                        style: const TextStyle(
                          fontSize: AppSpacing.size8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: "${dua.arabic}\n\n${dua.translation}",
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Dua copied to clipboard"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(
                      LucideIcons.copy,
                      size: 20,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Arabic Text
          Text(
            dua.arabic,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: fontName,
              fontSize: ayahTextSize,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : Colors.black,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 14),

          /// Transliteration
          if (dua.transliteration != null &&
              dua.transliteration!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkScaffold : const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dua.transliteration!,
                style: TextStyle(
                  fontSize: transliterationTextSize,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppTheme.darkTextSecondary : Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          /// Translation
          Text(
            dua.translation,
            style: TextStyle(
              fontSize: translationTextSize,
              color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          /// Reference / Source
          Text(
            referenceText,
            style: TextStyle(
              fontSize: referenceTextSize,
              fontWeight: FontWeight.w600,
              color: AppColors.emerald600,
            ),
          ),
        ],
      ),
    );
  }
}
