import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import 'package:quran_app/features/reflection/domain/models/reflection_model.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart'; // Add intl to pubspec.yaml for date formatting

class ReflectionCard extends ConsumerWidget {
  final ReflectionUIModel data;

  const ReflectionCard(this.data, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const colorMidGray = Color(0xFF4A4A4A);
    const colorDeepGray = Color(0xFF111827);
    const colorAmberBG = Color(0xFFFFEFA7);
    const colorDeepGoldText = Color(0xFF936312);
    const colorLightGrayBorder = Color(0xFFD4D4D8);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorLightGrayBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Badges, Date, and Trash
          Row(
            children: [
              _badge(data.surah.nameEnglish, colorAmberBG, colorDeepGoldText),
              const SizedBox(width: 8),
              _badge(
                "Verse ${data.ayahNumber}",
                Colors.white,
                colorMidGray,
                border: true,
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, yyyy').format(data.date),
                style: const TextStyle(
                  color: colorLightGrayBorder,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: colorLightGrayBorder,
                ),
                onPressed: () async {
                  await ref
                      .read(reflectionServiceProvider)
                      .deleteReflection(data.id);
                  ref.invalidate(reflectionsProvider);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Reflection Content
          Text(
            data.content,
            style: const TextStyle(
              color: colorMidGray,
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          // Footer Button
          SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () {
                // Set states and navigate to reader
                ref.read(readingModeProvider.notifier).state =
                    ReadingMode.translation;
                ref.read(selectedSurahProvider.notifier).state = data.surah;
                context.go('/readAyah');
              },
              icon: const Icon(
                Icons.book_outlined,
                size: 16,
                color: colorDeepGray,
              ),
              label: const Text(
                "Read Full Surah",
                style: TextStyle(
                  color: colorDeepGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: colorLightGrayBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
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
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
