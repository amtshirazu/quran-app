import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';

import '../../../../core/constants/app_spacing.dart';

class PrayerTimesHeader extends ConsumerWidget implements PreferredSizeWidget {
  const PrayerTimesHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationAsync = ref.watch(countryAndCityNameProvider);

    final locationText = locationAsync.when(
      data: (data) {
        final city = data['city'] ?? 'Location';
        final country = data['country'] ?? '';
        if (country.isNotEmpty && country != city) {
          return '$city, $country';
        }
        return city;
      },
      loading: () => 'Fetching location...',
      error: (_, __) => 'Location unavailable',
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkScaffold : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.deepGreen, AppColors.emerald600],
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 16, 16),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  LucideIcons.arrowLeft,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Prayer Times',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        color: AppColors.emerald100,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        locationText,
                        style: const TextStyle(
                          color: AppColors.emerald100,
                          fontSize: AppSpacing.size12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
