import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class AboutLicensesScreen extends StatelessWidget {
  const AboutLicensesScreen({super.key});

  static const List<Map<String, String>> _licenses = [
    {'name': 'muslim_data_flutter', 'license': 'Apache 2.0'},
    {'name': 'share_plus', 'license': 'BSD-3'},
    {'name': 'just_audio', 'license': 'MIT'},
    {'name': 'just_audio_background', 'license': 'MIT'},
    {'name': 'flutter_riverpod', 'license': 'MIT'},
    {'name': 'go_router', 'license': 'BSD-3'},
    {'name': 'dio', 'license': 'MIT'},
    {'name': 'sqflite', 'license': 'MIT'},
    {'name': 'path_provider', 'license': 'BSD-3'},
    {'name': 'flutter_svg', 'license': 'MIT'},
    {'name': 'lucide_icons_flutter', 'license': 'ISC'},
    {'name': 'flutter_launcher_icons', 'license': 'MIT'},
    {'name': 'visibility_detector', 'license': 'Apache 2.0'},
    {'name': 'intl', 'license': 'BSD-3'},
    {'name': 'adhan', 'license': 'MIT'},
    {'name': 'geolocator', 'license': 'MIT'},
    {'name': 'geocoding', 'license': 'MIT'},
    {'name': 'quran', 'license': 'MIT'},
    {'name': 'shimmer', 'license': 'MIT'},
    {'name': 'qcf_quran_plus', 'license': 'MIT'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkScaffold : null,
            gradient: isDark
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.deepGreen,
                      AppColors.emerald600,
                    ],
                  ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/about');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Open-source licenses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12),
              child: Text(
                'This app uses the following open-source packages.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _licenses.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFF3F4F6),
                ),
                itemBuilder: (context, index) {
                  final item = _licenses[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppColors.gray900,
                          ),
                        ),
                        Text(
                          item['license']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
