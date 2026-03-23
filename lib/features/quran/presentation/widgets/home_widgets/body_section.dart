import 'package:flutter/material.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/continue_reading_card.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/life_situation_finder.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/quick_access.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/reflection_journal.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/study_plan_card.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/verse_of_day_card.dart';






class BodySection extends StatelessWidget {
  const BodySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContinueReadingCard(),
        DailyVerseCard(),
        LifeSituationCard(),
        StudyPlanCard(),
        QuickAccess(),
        ReflectionJournalCard(),
      ],
    );
  }
}
