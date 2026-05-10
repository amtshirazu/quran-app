import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';
import 'package:quran_app/shimeers/next_prayer_shimmer.dart';
import '../../../../../core/constants/app_colors.dart';

class NextPrayerCard extends ConsumerWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final model = ref.watch(nextPrayerUIProvider);

    return prayerTimesAsync.when(
      data: (_) {
        if (model == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(AppSpacing.size12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.1),
            borderRadius: BorderRadius.circular(AppSpacing.size16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.emerald500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Next Prayer",
                        style: TextStyle(
                          color: AppColors.emerald100,
                          fontSize: AppSpacing.size12,
                        ),
                      ),
                      Text(
                        model.prayerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: AppSpacing.size14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    model.formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.size18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    model.remainingTime,
                    style: const TextStyle(
                      color: AppColors.emerald100,
                      fontSize: AppSpacing.size12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const NextPrayerShimmer(),
      error: (err, _) => const SizedBox.shrink(),
    );
  }
}
