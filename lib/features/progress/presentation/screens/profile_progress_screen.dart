import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../state/profile_progress_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/motivation_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/progress_metric.dart';
import '../widgets/quran_progress_card.dart';







class ProfileProgressScreen extends ConsumerWidget {
  const ProfileProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider);
    final since = ref.watch(profileSinceProvider);
    final progress = ref.watch(quranCompletionProvider);
    final streak = ref.watch(streakProvider);
    final verses = ref.watch(versesReadProvider);
    final surahs = ref.watch(surahsReadProvider);
    final motivationTitle = ref.watch(motivationTitleProvider);
    final motivationSubtitle = ref.watch(motivationSubtitleProvider);

    return Scaffold(
      backgroundColor: AppColors.emerald50,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.emerald50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(name: name, since: since),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Column(
                    children: [
                      QuranProgressCard(
                        progress: progress,
                        streak: streak,
                        verses: verses,
                        surahs: surahs,
                      ),
                      const SizedBox(height: 16),
                      MotivationCard(
                        title: motivationTitle,
                        subtitle: motivationSubtitle,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
