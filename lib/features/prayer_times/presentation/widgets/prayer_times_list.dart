import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/notifications/notification_service.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/location_access_card.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/prayer_times_card.dart';

class PrayerTimesList extends ConsumerStatefulWidget {
  const PrayerTimesList({super.key});

  @override
  ConsumerState<PrayerTimesList> createState() => _PrayerTimesListState();
}

class _PrayerTimesListState extends ConsumerState<PrayerTimesList> {
  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final enabledPrayers = ref.watch(enabledPrayersProvider);

    return prayerTimesAsync.when(
      data: (times) {
        final prayerKeys = times.keys.where((key) => key != "Sunrise").toList();

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.size20),
          itemCount: prayerKeys.length,
          itemBuilder: (context, index) {
            final name = prayerKeys[index];
            final time = times[name]!;
            final isEnabled = enabledPrayers.contains(name);

            return PrayerTimeCard(
              prayerName: name,
              prayerTime: DateFormat.jm().format(time),
              isEnabled: isEnabled,
              onToggle: (val) async {
                if (val) {
                  final hasPermission = await NotificationService.instance
                      .checkAndRequestPermission(context);
                  if (!hasPermission) return;
                }
                await ref.read(enabledPrayersProvider.notifier).togglePrayer(name, val);
                final currentTimes = ref.read(prayerTimesProvider).asData?.value;
                if (currentTimes != null) {
                  final activePrayers = ref.read(enabledPrayersProvider);
                  await NotificationService.instance.schedule7DayPrayerNotifications(
                    todayTimes: currentTimes,
                    enabledPrayers: activePrayers,
                  );
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.size20),
          child: LocationAccessCard(
            onEnablePressed: () async {
              LocationPermission permission =
                  await Geolocator.checkPermission();

              if (permission == LocationPermission.deniedForever) {
                await Geolocator.openAppSettings();
              } else {
                ref.invalidate(locationProvider);
              }
            },
          ),
        );
      },
    );
  }
}
