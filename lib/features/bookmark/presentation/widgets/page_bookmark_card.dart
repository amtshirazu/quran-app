import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

    // Colors extracted from your provided image
    const colorTealBG = Color(0xFFD1FAE5);
    const colorTealText = Color(0xFF065F46);
    const colorLightGrayBorder = Color(0xFFD4D4D8);
    const colorMidGray = Color(0xFF4A4A4A);
    const colorDeepGray = Color(0xFF111827);
    const colorNoteBG = Color(0xFFFFF9E5);
    const colorBrownText = Color(0xFF8B5E3C);

    return Card(
      elevation: 0, // Flat look as per image
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorLightGrayBorder.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (badges + delete)
            Row(
              children: [
                _badge("Page ${b.page}", colorTealBG, colorTealText),
                const SizedBox(width: 8),
                _badge(
                  "Juz ${data.juz}",
                  Colors.white,
                  colorMidGray,
                  border: true,
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: colorMidGray,
                  ),
                  color: colorLightGrayBorder,
                  onPressed: () {
                    ref.read(bookmarkServiceProvider).deleteBookmark(b.id!);
                    ref.invalidate(pageBookmarkUIProvider);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // SURAH NAME
            Text(
              data.surahName,
              style: const TextStyle(
                color: colorMidGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),

            // ARABIC PREVIEW
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                data.arabicPreview,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Uthmani',
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // NOTE
            if (b.note != null && b.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorNoteBG,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "📝 ${b.note!}",
                  style: const TextStyle(color: colorBrownText, fontSize: 14),
                ),
              ),

            const SizedBox(height: 16),

            // BUTTON
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
                  side: const BorderSide(color: colorLightGrayBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Open Page",
                  style: TextStyle(
                    color: colorDeepGray,
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

  Widget _badge(String text, Color bg, Color color, {bool border = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border ? Border.all(color: const Color(0xFFD4D4D8)) : null,
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
