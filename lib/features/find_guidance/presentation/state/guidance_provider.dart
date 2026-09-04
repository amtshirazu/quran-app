import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/quran/presentation/state/translation_provider.dart';
import '../../data/guidance_database_service.dart';
import '../../domain/model/guidance_category.dart';
import '../../domain/model/guidance_verse.dart';

final guidanceDatabaseServiceProvider = Provider<GuidanceDatabaseService>((ref) {
  return GuidanceDatabaseService();
});

/// Holds the currently selected emotion category (null when on main list)
final selectedEmotionProvider = StateProvider<String?>((ref) => null);

/// Category visual configuration matching the design
final Map<String, Map<String, dynamic>> _categoryVisuals = {
  'Stressed': {
    'icon': LucideIcons.cloudRain,
    'iconColor': Color(0xFF2563EB),
    'backgroundColor': Color(0xFFDBEAFE),
  },
  'Grateful': {
    'icon': LucideIcons.heart,
    'iconColor': Color(0xFF059669),
    'backgroundColor': Color(0xFFD1FAE5),
  },
  'Sad': {
    'icon': LucideIcons.cloudDrizzle,
    'iconColor': Color(0xFF6366F1),
    'backgroundColor': Color(0xFFE0E7FF),
  },
  'Hopeless': {
    'icon': LucideIcons.sun,
    'iconColor': Color(0xFFEA580C),
    'backgroundColor': Color(0xFFFFEDD5),
  },
  'Seeking Forgiveness': {
    'icon': LucideIcons.sparkles,
    'iconColor': Color(0xFF9333EA),
    'backgroundColor': Color(0xFFF3E8FF),
  },
  'Need Motivation': {
    'icon': LucideIcons.zap,
    'iconColor': Color(0xFFD97706),
    'backgroundColor': Color(0xFFFEF3C7),
  },
  'In Awe': {
    'icon': LucideIcons.compass,
    'iconColor': Color(0xFF0284C7),
    'backgroundColor': Color(0xFFE0F2FE),
  },
  'Seeking Wisdom': {
    'icon': LucideIcons.bookOpen,
    'iconColor': Color(0xFF0D9488),
    'backgroundColor': Color(0xFFCCFBF1),
  },
};

/// Order of display for the categories
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

final guidanceCategoriesProvider = FutureProvider<List<GuidanceCategory>>((ref) async {
  final service = ref.watch(guidanceDatabaseServiceProvider);
  final counts = await service.getEmotionVerseCounts();

  final List<GuidanceCategory> categories = [];

  for (final emotion in _orderedEmotions) {
    if (counts.containsKey(emotion)) {
      final visual = _categoryVisuals[emotion] ?? {
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

/// Fetches verses for a specific emotion and enriches them with Arabic text & English translation
final guidanceVersesProvider = FutureProvider.family<List<GuidanceVerse>, String>((ref, emotion) async {
  final dbService = ref.watch(guidanceDatabaseServiceProvider);
  final translationService = ref.watch(translationServiceProvider);

  final rawVerses = await dbService.getVersesByEmotion(emotion);

  final List<GuidanceVerse> enriched = [];

  for (final verse in rawVerses) {
    // Get Arabic text from quran package
    final arabicText = quran.getVerse(
      verse.surahNum,
      verse.ayahNum,
      verseEndSymbol: false,
    );

    // Get English translation from Pickthall DB
    String translationText = "";
    try {
      translationText = await translationService.getTranslation(
        verse.surahNum,
        verse.ayahNum,
      );
    } catch (_) {
      translationText = "";
    }

    // Get Surah Name
    final surahName = quran.getSurahName(verse.surahNum);

    enriched.add(
      verse.copyWith(
        arabicText: arabicText,
        translation: translationText,
        surahName: surahName,
      ),
    );
  }

  return enriched;
});
