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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${data.surah.nameEnglish} ${b.ayahNumber}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 20),
                  onPressed: () {
                    ref.read(bookmarkServiceProvider).deleteBookmark(b.id!);
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
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Uthmani',
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TRANSLATION
            Text(data.translation, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 12),

            // NOTE
            if (b.note != null && b.note!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("📝 ${b.note!}"),
              ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                ref.read(readingModeProvider.notifier).state =
                    ReadingMode.translation;
                ref.read(selectedSurahProvider.notifier).state = data.surah;
                context.go('/readAyahs');
              },
              child: const Text("Read Full Surah"),
            ),
          ],
        ),
      ),
    );
  }
}
