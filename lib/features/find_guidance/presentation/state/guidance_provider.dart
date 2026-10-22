import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/core/constants/app_colors.dart';
import '../../data/guidance_database_service.dart';
import '../../domain/model/guidance_category.dart';
import '../../domain/model/guidance_verse.dart';

final guidanceDatabaseServiceProvider = Provider<GuidanceDatabaseService>((
  ref,
) {
  return GuidanceDatabaseService();
});

/// Holds currently selected emotion category (null when on main list)
final selectedEmotionProvider = StateProvider<String?>((ref) => null);

/// Category visual configuration
final Map<String, Map<String, dynamic>> _categoryVisuals = {
  'Stressed': {
    'icon': LucideIcons.cloudRain,
    'iconColor': const Color(0xFF2563EB),
    'backgroundColor': const Color(0xFFDBEAFE),
  },
  'Grateful': {
    'icon': LucideIcons.heart,
    'iconColor': const Color(0xFF059669),
    'backgroundColor': const Color(0xFFD1FAE5),
  },
  'Sad': {
    'icon': LucideIcons.cloudDrizzle,
    'iconColor': const Color(0xFF6366F1),
    'backgroundColor': const Color(0xFFE0E7FF),
  },
  'Hopeless': {
    'icon': LucideIcons.sun,
    'iconColor': const Color(0xFFEA580C),
    'backgroundColor': const Color(0xFFFFEDD5),
  },
  'Seeking Forgiveness': {
    'icon': LucideIcons.sparkles,
    'iconColor': const Color(0xFF9333EA),
    'backgroundColor': const Color(0xFFF3E8FF),
  },
  'Need Motivation': {
    'icon': LucideIcons.zap,
    'iconColor': const Color(0xFFD97706),
    'backgroundColor': const Color(0xFFFEF3C7),
  },
  'In Awe': {
    'icon': LucideIcons.compass,
    'iconColor': const Color(0xFF0284C7),
    'backgroundColor': const Color(0xFFE0F2FE),
  },
  'Seeking Wisdom': {
    'icon': LucideIcons.bookOpen,
    'iconColor': const Color(0xFF0D9488),
    'backgroundColor': const Color(0xFFCCFBF1),
  },
};

final List<String> _orderedEmotions = [
  'Stressed',
  'Grateful',
  'Sad',
  'Hopeless',
  'Seeking Forgiveness',
  'Need Motivation',
  'In Awe',
  'Seeking Wisdom',
];

final guidanceCategoriesProvider = FutureProvider<List<GuidanceCategory>>((
  ref,
) async {
  ref.keepAlive();
  final service = ref.watch(guidanceDatabaseServiceProvider);
  final counts = await service.getEmotionVerseCounts();

  final List<GuidanceCategory> categories = [];

  for (final emotion in _orderedEmotions) {
    if (counts.containsKey(emotion)) {
      final visual =
          _categoryVisuals[emotion] ??
          {
            'icon': LucideIcons.helpCircle,
            'iconColor': AppColors.purple600,
            'backgroundColor': AppColors.purple100,
          };

      categories.add(
        GuidanceCategory(
          emotion: emotion,
          verseCount: counts[emotion] ?? 0,
          icon: visual['icon'] as IconData,
          iconColor: visual['iconColor'] as Color,
          backgroundColor: visual['backgroundColor'] as Color,
        ),
      );
    }
  }

  return categories;
});

/// Offloads heavy string lookups and model enrichment to a background isolate
List<GuidanceVerse> _enrichVersesWorker(List<GuidanceVerse> rawVerses) {
  final List<GuidanceVerse> enriched = [];

  for (final verse in rawVerses) {
    final arabicText = quran.getVerse(
      verse.surahNum,
      verse.ayahNum,
      verseEndSymbol: false,
    );
    final surahName = quran.getSurahName(verse.surahNum);

    enriched.add(
      verse.copyWith(
        arabicText: arabicText,
        translation:
            (verse.translation != null && verse.translation!.isNotEmpty)
            ? verse.translation!
            : quran.getVerseTranslation(verse.surahNum, verse.ayahNum),
        surahName: surahName,
      ),
    );
  }

  return enriched;
}

/// Fetches verses for a specific emotion and enriches them in a background isolate
final guidanceVersesProvider =
    FutureProvider.family<List<GuidanceVerse>, String>((ref, emotion) async {
      ref.keepAlive();
      final dbService = ref.watch(guidanceDatabaseServiceProvider);

      final rawVerses = await dbService.getVersesByEmotion(emotion);

      if (rawVerses.length < 50) {
        return _enrichVersesWorker(rawVerses);
      }

      return await Isolate.run(() => _enrichVersesWorker(rawVerses));
    });
