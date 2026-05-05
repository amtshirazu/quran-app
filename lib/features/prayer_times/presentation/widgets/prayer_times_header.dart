import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';

class PrayerTimesHeader extends ConsumerWidget implements PreferredSizeWidget {
  const PrayerTimesHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(countryAndCityNameProvider);

    return Container(
      color: AppColors.emerald600,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment
              .center, // This centers the arrow with the text block
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wraps height to content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Prayer Times",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2, // Adjusts line height for tighter grouping
                    ),
                  ),
                  locationAsync.when(
                    data: (data) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${data['city']}, ${data['country']}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Text(
                      "Detecting location...",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    error: (_, __) => const Text(
                      "Location unknown",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
