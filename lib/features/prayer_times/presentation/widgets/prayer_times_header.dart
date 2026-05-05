import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';

class PrayerTimesHeader extends ConsumerWidget {
  const PrayerTimesHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(countryAndCityNameProvider);

    return Container(
      color: AppColors.emerald600,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.size20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Prayer Times",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                locationAsync.when(
                  data: (data) => Text(
                    "${data['city']}, ${data['country']}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  loading: () => const Text(
                    "Detecting...",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  error: (_, __) => const Text(
                    "Location unavailable",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
