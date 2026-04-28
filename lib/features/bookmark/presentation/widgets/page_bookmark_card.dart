import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (badges + delete)
            Row(
              children: [
                _badge(
                  "Page ${b.page}",
                  Colors.green.shade50,
                  Colors.green.shade800,
                ),
                const SizedBox(width: 8),
                _badge(
                  "Juz ${data.juz}",
                  Colors.white,
                  Colors.grey,
                  border: true,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    ref.read(bookmarkServiceProvider).deleteBookmark(b.id!);

                    ref.invalidate(pageBookmarkUIProvider);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // SURAH NAME
            Text(
              data.surahName,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 6),

            // ARABIC PREVIEW
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                data.arabicPreview,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Uthmani',
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // NOTE
            if (b.note != null && b.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("📝 ${b.note!}"),
              ),

            const SizedBox(height: 12),

            // BUTTON
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(readingModeProvider.notifier).state =
                      ReadingMode.reading;
                  ref.read(shouldResumeLastReadProvider.notifier).state = false;
                  ref.read(jumpToPageProvider.notifier).state =
                      b.page; // Set the page to jump to when reader opens
                  context.go('/readAyahs');
                },
                child: const Text("Open Page"),
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
        border: border ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
