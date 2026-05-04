import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/bookmark/domain/model/verse_model.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';

class VerseBookmarkCard extends ConsumerWidget {
  final VerseBookmarkUI data;

  const VerseBookmarkCard(this.data, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = data.bookmark;

    // Precise colors from image_54be28.png
    const colorMidGray = Color(0xFF4A4A4A);
    const colorDeepGray = Color(0xFF111827);
    const colorAmberBG = Color(0xFFFFEFA7);
    const colorDeepGoldText = Color(0xFF936312);
    const colorNoteBG = Color(0xFFFFF9E5);
    const colorBrownText = Color(0xFF8B5E3C);
    const colorLightGrayBorder = Color(0xFFD4D4D8);

    return Card(
      elevation: 0, // Set to 0 to match the flat look of the image
      color: Colors.white, // White card background as requested
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorLightGrayBorder.withOpacity(0.5),
        ), // Subtle border
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorAmberBG, // Updated to image_54be28.png color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${data.surah.nameEnglish} ${b.ayahNumber}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:
                          colorDeepGoldText, // Updated to image_54be28.png color
                    ),
                  ),
                ),
                const Spacer(),
                // Adjusted Trash Icon styling to match the image
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
                    ref.invalidate(verseBookmarkUIProvider);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ARABIC
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                data.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontFamily: 'Uthmani',
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TRANSLATION
            Text(
              data.translation,
              style: const TextStyle(
                color: colorMidGray, // Updated to image_54be28.png color
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // NOTE
            if (b.note != null && b.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorNoteBG, // Updated to image_54be28.png color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "📝 ${b.note!}",
                  style: const TextStyle(
                    color: colorBrownText, // Updated to image_54be28.png color
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // BUTTON
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
                  side: const BorderSide(color: colorLightGrayBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Read Full Surah",
                  style: TextStyle(
                    color: colorDeepGray, // Updated to image_54be28.png color
                    fontSize: 13,
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
