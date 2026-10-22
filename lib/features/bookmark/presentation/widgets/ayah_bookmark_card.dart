import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/domain/model/verse_model.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';

import '../../../../core/constants/app_spacing.dart';

class VerseBookmarkCard extends ConsumerWidget {
  final VerseBookmarkUI data;

  const VerseBookmarkCard(this.data, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = data.bookmark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const colorMidGray = Color(0xFF4A4A4A);
    const colorDeepGray = Color(0xFF111827);
    const colorAmberBG = Color(0xFFFFEFA7);
    const colorDeepGoldText = Color(0xFF936312);
    const colorNoteBG = Color(0xFFFFF9E5);
    const colorBrownText = Color(0xFF8B5E3C);
    const colorLightGrayBorder = Color(0xFFD4D4D8);

    return Card(
      elevation: isDark ? 0 : 0,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? AppTheme.darkBorder
              : colorLightGrayBorder.withAlpha(128),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.emerald600.withAlpha(38)
                        : colorAmberBG,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${data.surah.nameEnglish} ${b.ayahNumber}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isDark ? AppColors.emerald600 : colorDeepGoldText,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: isDark ? AppTheme.darkTextSecondary : colorMidGray,
                  ),
                  onPressed: () {
                    ref.read(bookmarkServiceProvider).deleteBookmark(b.id!);
                    ref.invalidate(verseBookmarkUIProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                data.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                  fontSize: 22,
                  fontFamily: 'Uthmanic',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.translation,
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : colorMidGray,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            if (b.note != null && b.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkScaffold : colorNoteBG,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "📝 ${b.note!}",
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : colorBrownText,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(readingModeProvider.notifier).state =
                      ReadingMode.translation;
                  ref.read(selectedSurahProvider.notifier).state = data.surah;
                  context.go('/readAyah');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? AppTheme.darkBorder : colorLightGrayBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Read Full Surah",
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextPrimary : colorDeepGray,
                    fontSize: AppSpacing.size12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
