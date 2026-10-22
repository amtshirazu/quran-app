import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/settings/presentation/state/display_settings_provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/model/guidance_verse.dart';
import 'guidance_bookmark_dialog.dart';

class GuidanceVerseCard extends ConsumerWidget {
  final GuidanceVerse verse;

  const GuidanceVerseCard({super.key, required this.verse});

  void _navigateToSurah(BuildContext context, WidgetRef ref) {
    final surahs = ref.read(surahListProvider).value;
    final surah = surahs?.firstWhere(
      (s) => s.number == verse.surahNum,
      orElse: () => surahs.first,
    );

    if (surah != null) {
      ref.read(selectedSurahProvider.notifier).state = surah;
      ref.read(shouldResumeLastReadProvider.notifier).state = false;
      context.push('/readAyah');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quranScript = ref.watch(quranScriptProvider);
    final ayahTextSize = ref.watch(ayahTextSizeProvider);
    final translationTextSize = ref.watch(translationTextSizeProvider);
    final referenceTextSize = ref.watch(referenceTextSizeProvider);

    final fontName = quranScript == 'IndoPak' ? "Indo Park" : "Uthmanic";

    final isBookmarked = ref.watch(
      isAyahBookmarkedProvider((
        surahId: verse.surahNum,
        ayahNumber: verse.ayahNum,
      )),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppColors.gray200,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            /// Arabic Verse Text
            if (verse.arabicText != null && verse.arabicText!.isNotEmpty) ...[
              Text(
                verse.arabicText!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: ayahTextSize,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                  fontFamily: fontName,
                ),
              ),
              const SizedBox(height: 12),
            ],

            /// English Translation
            if (verse.translation != null && verse.translation!.isNotEmpty) ...[
              Text(
                '"${verse.translation}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: translationTextSize,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppColors.gray700,
                ),
              ),
              const SizedBox(height: 8),
            ],

            /// Reference (Surah & Verse Number)
            Text(
              'Surah ${verse.surahNum}, Verse ${verse.ayahNum}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: referenceTextSize,
                color: isDark ? AppTheme.darkTextSecondary : AppColors.gray500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            /// "Why this verse?" Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkScaffold : AppColors.emerald50,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why this verse?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    verse.whyThisVerse,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : const Color(0xFF064E3B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? AppTheme.darkBorder : AppColors.gray300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _navigateToSurah(context, ref),
                    child: Text(
                      'Read Full Surah',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppColors.gray900,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSpacing.size12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                IconButton.outlined(
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppTheme.darkScaffold
                        : (isBookmarked
                              ? const Color(0xFFFEF2F2)
                              : Colors.white),
                    side: BorderSide(
                      color: isBookmarked
                          ? const Color(0xFFFCA5A5)
                          : (isDark ? AppTheme.darkBorder : AppColors.gray300),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: () async {
                    final bookmarkService = ref.read(bookmarkServiceProvider);

                    if (isBookmarked) {
                      final allBookmarks = await ref.read(
                        bookmarksProvider.future,
                      );
                      final existing = allBookmarks.where(
                        (b) =>
                            b.type == BookmarkType.verse &&
                            b.surahId == verse.surahNum &&
                            b.ayahNumber == verse.ayahNum,
                      );
                      if (existing.isNotEmpty) {
                        await bookmarkService.deleteBookmark(
                          existing.first.id!,
                        );
                        ref.invalidate(bookmarksProvider);
                      }
                    } else {
                      final note = await showGuidanceBookmarkDialog(
                        context,
                        verse: verse,
                      );

                      if (note != null) {
                        await bookmarkService.addOrUpdateVerseBookmark(
                          surahId: verse.surahNum,
                          ayahNumber: verse.ayahNum,
                          note: note,
                        );
                        ref.invalidate(bookmarksProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.emerald500,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Saved to Bookmarks',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF065F46),
                                        ),
                                      ),
                                      Text(
                                        '${verse.surahName ?? 'Surah ${verse.surahNum}'} ${verse.ayahNum}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF064E3B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () => context.push('/bookmarks'),
                                    child: const Text(
                                      'View',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.emerald50,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: Icon(
                    LucideIcons.heart,
                    size: 18,
                    color: isBookmarked
                        ? const Color(0xFFEF4444)
                        : (isDark
                              ? AppTheme.darkTextSecondary
                              : AppColors.gray700),
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
