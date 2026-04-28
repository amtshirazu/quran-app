import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/progress/presentation/widgets/profile_header.dart';
import 'package:quran_app/features/progress/presentation/widgets/quran_progress_card.dart';
import 'package:quran_app/features/progress/presentation/widgets/motivation_card.dart';

class ProfileProgressScreen extends ConsumerWidget {
  const ProfileProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider);
    final sinceAsync = ref.watch(profileSinceProvider);
    final motivationTitle = ref.watch(motivationTitleProvider);
    final motivationSubtitle = ref.watch(motivationSubtitleProvider);

    final progressAsync = ref.watch(profileProgressProvider);

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

        // 👇 First resolve BOTH async values
        child: progressAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),

          data: (data) {
            return sinceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildContent(
                name: name,
                since: 'Start your journey today',
                data: data,
                motivationTitle: motivationTitle,
                motivationSubtitle: motivationSubtitle,
              ),

              data: (since) {
                return _buildContent(
                  name: name,
                  since: since,
                  data: data,
                  motivationTitle: motivationTitle,
                  motivationSubtitle: motivationSubtitle,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent({
    required String name,
    required String since,
    required dynamic data,
    required String motivationTitle,
    required String motivationSubtitle,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeader(name: name, since: since),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Column(
                children: [
                  QuranProgressCard(
                    progress: data.progress,
                    streak: data.streak,
                    verses: data.verses,
                    surahs: data.surahs,
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
    );
  }
}
