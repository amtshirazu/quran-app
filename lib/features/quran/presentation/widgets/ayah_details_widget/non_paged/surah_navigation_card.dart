import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../state/quran_providers.dart';

class SurahNavigationCard extends ConsumerWidget {
  const SurahNavigationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurah = ref.watch(selectedSurahProvider);
    final surahAsync = ref.watch(surahListProvider);
    final textTheme = Theme.of(context).textTheme;

    if (selectedSurah == null) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return surahAsync.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
      data: (surahs) {
        final currentIndex = surahs.indexWhere(
          (s) => s.number == selectedSurah.number,
        );

        if (currentIndex == -1) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        final hasPrevious = currentIndex > 0;
        final hasNext = currentIndex < surahs.length - 1;

        final previousSurah = hasPrevious ? surahs[currentIndex - 1] : null;
        final nextSurah = hasNext ? surahs[currentIndex + 1] : null;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.emerald500, AppColors.emerald600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasPrevious)
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            ref.read(selectedSurahProvider.notifier).state =
                                previousSurah;
                            context.go("/readAyah");
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.arrowLeft,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Previous",
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppSpacing.size14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                previousSurah!.nameEnglish,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppSpacing.size12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (hasPrevious && hasNext) const SizedBox(width: 20),

                    if (hasNext)
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            ref.read(selectedSurahProvider.notifier).state =
                                nextSurah;
                            context.go("/readAyah");
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Next",
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppSpacing.size14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    LucideIcons.arrowRight,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextSurah!.nameEnglish,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppSpacing.size12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
