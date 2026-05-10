import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/location_access_card.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/prayer_times_card.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/qibla_button.dart';

class PrayerTimesList extends ConsumerStatefulWidget {
  const PrayerTimesList({super.key});

  @override
  ConsumerState<PrayerTimesList> createState() => _PrayerTimesListState();
}

class _PrayerTimesListState extends ConsumerState<PrayerTimesList> {
  final Map<String, bool> _toggles = {};

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    return prayerTimesAsync.when(
      data: (times) {
        // Filter out 'Sunrise' so only the 5 daily prayers remain
        final prayerKeys = times.keys.where((key) => key != "Sunrise").toList();

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.size20),
          itemCount: prayerKeys.length + 1, // Prayers + Qibla Button
          itemBuilder: (context, index) {
            if (index == prayerKeys.length) {
              return const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: QiblaButton(),
              );
            }

            final name = prayerKeys[index];
            final time = times[name]!;

            return PrayerTimeCard(
              prayerName: name,
              prayerTime: DateFormat.jm().format(time),
              isEnabled: _toggles[name] ?? true,
              onToggle: (val) => setState(() => _toggles[name] = val),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        return Padding(
          padding: EdgeInsets.all(AppSpacing.size20),
          child: LocationAccessCard(
            onEnablePressed: () async {
              LocationPermission permission =
                  await Geolocator.checkPermission();

              if (permission == LocationPermission.deniedForever) {
                // Open app settings so user can enable location permissions
                await Geolocator.openAppSettings();
              } else {
                // Invalidating locationProvider to trigger a refetch of GPS coordinates
                ref.invalidate(locationProvider);
              }
            },
          ),
        );
      },
    );
  }
}
