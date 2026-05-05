import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_time_provider.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/prayer_times_card.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/qibla_button.dart';

class PrayerTimesList extends ConsumerStatefulWidget {
  const PrayerTimesList({super.key});

  @override
  ConsumerState<PrayerTimesList> createState() => _PrayerTimesListState();
}

class _PrayerTimesListState extends ConsumerState<PrayerTimesList> {
  // Simple state for toggles
  final Map<String, bool> _toggles = {};

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);

    return prayerTimesAsync.when(
      data: (times) {
        final sortedKeys = times.keys.toList();

        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.size20),
          // +1 to accommodate the Qibla Button at the end
          itemCount: sortedKeys.length + 1,
          itemBuilder: (context, index) {
            // Check if we are at the last index
            if (index == sortedKeys.length) {
              return const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: QiblaButton(),
              );
            }

            final name = sortedKeys[index];
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
      error: (err, _) => Center(child: Text("Error loading times: $err")),
    );
  }
}
