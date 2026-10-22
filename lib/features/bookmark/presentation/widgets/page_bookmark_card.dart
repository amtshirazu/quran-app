import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/domain/model/page_model.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';

class PageBookmarkCard extends ConsumerWidget {
  final PageBookmarkUI data;

  const PageBookmarkCard(this.data, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = data.bookmark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const colorTealBG = Color(0xFFD1FAE5);
    const colorTealText = Color(0xFF065F46);
    const colorLightGrayBorder = Color(0xFFD4D4D8);
    const colorMidGray = Color(0xFF4A4A4A);
    const colorDeepGray = Color(0xFF111827);
    const colorNoteBG = Color(0xFFFFF9E5);
    const colorBrownText = Color(0xFF8B5E3C);

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
                _badge(
                  "Page ${b.page}",
                  isDark ? AppColors.emerald600.withAlpha(38) : colorTealBG,
                  isDark ? AppColors.emerald600 : colorTealText,
                ),
                const SizedBox(width: 8),
                _badge(
                  "Juz ${data.juz}",
                  isDark ? AppTheme.darkScaffold : Colors.white,
                  isDark ? AppTheme.darkTextSecondary : colorMidGray,
                  border: true,
                  isDark: isDark,
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
                    ref.invalidate(pageBookmarkUIProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.surahName,
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : colorMidGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                data.arabicPreview,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Uthmanic',
                  height: 1.6,
                  color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () async {
                  ref.read(readingModeProvider.notifier).state =
                      ReadingMode.reading;
                  ref.read(shouldResumeLastReadProvider.notifier).state = false;
                  ref.read(jumpToPageProvider.notifier).state = b.page;

                  final surahs = await ref.read(surahListProvider.future);
                  final targetSurah = surahs.firstWhere(
                    (s) => s.number == b.surahId,
                  );
                  ref.read(selectedSurahProvider.notifier).state = targetSurah;

                  ref.read(currentPageSurahIdProvider.notifier).state =
                      b.surahId;
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
                  "Open Page",
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextPrimary : colorDeepGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
    String text,
    Color bg,
    Color color, {
    bool border = false,
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border
            ? Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFD4D4D8),
              )
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
