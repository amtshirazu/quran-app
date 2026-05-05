import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/prayer_times_header.dart';
import 'package:quran_app/features/prayer_times/presentation/widgets/prayer_times_list.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emerald50, // Light background for the list
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: PrayerTimesHeader(),
      ),
      body: const PrayerTimesList(),
    );
  }
}
