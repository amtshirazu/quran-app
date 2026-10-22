import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import 'package:quran_app/features/reflection/domain/models/reflection_model.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart';

class ReflectionCard extends ConsumerWidget {
  final ReflectionUIModel data;

  const ReflectionCard(this.data, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const colorAmberBG = Color(0xFFFFEFA7);
    const colorDeepGoldText = Color(0xFF936312);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.darkBorder
              : const Color(0xFFD4D4D8).withAlpha(128),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge(data.surah.nameEnglish, colorAmberBG, colorDeepGoldText),
              const SizedBox(width: 8),
              _badge(
                "Verse ${data.ayahNumber}",
                isDark ? AppTheme.darkScaffold : Colors.white,
                isDark ? AppTheme.darkTextSecondary : const Color(0xFF4A4A4A),
                border: true,
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, yyyy').format(data.date),
                style: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : const Color(0xFF4A4A4A),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : const Color(0xFF4A4A4A),
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
          Text(
            data.content,
            style: TextStyle(
              color: isDark
                  ? AppTheme.darkTextPrimary
                  : const Color(0xFF111827),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(readingModeProvider.notifier).state =
                    ReadingMode.translation;
                ref.read(selectedSurahProvider.notifier).state = data.surah;
                context.go('/readAyah');
              },
              icon: Icon(
                LucideIcons.bookOpen,
                size: 18,
                color: isDark
                    ? AppColors.emerald600
                    : const Color.fromARGB(255, 9, 13, 22),
              ),
              label: Text(
                "Read Full Surah",
                style: TextStyle(
                  color: isDark
                      ? AppColors.emerald600
                      : const Color.fromARGB(255, 9, 13, 22),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFD4D4D8),
                ),
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
