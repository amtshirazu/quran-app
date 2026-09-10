import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class AboutPrivacyScreen extends StatelessWidget {
  const AboutPrivacyScreen({super.key});

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
                    'Privacy Policy',
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppColors.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated September 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppColors.gray500,
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'What We Store',
                body:
                    'Your settings, bookmarks, and downloaded audio are stored locally on your device. We do not require an account to use the app.',
                isDark: isDark,
              ),
              _buildSection(
                title: 'Audio Streaming',
                body:
                    'Streaming full surahs or individual ayahs sends requests directly to mp3Quran.net and EveryAyah.com. These third-party services may log standard technical data, such as IP address, as part of normal web requests. We do not receive or store this data ourselves.',
                isDark: isDark,
              ),
              _buildSection(
                title: 'Quran Content Sources',
                body:
                    'Quran text, fonts, tafsirs, and translations are provided through the Quranic Universal Library and do not involve transmitting personal data.',
                isDark: isDark,
              ),
              _buildSection(
                title: 'Your Data',
                body:
                    'We do not sell or share your data. You can clear downloads and reset settings at any time from within the app.',
                isDark: isDark,
              ),
              _buildSection(
                title: 'Contact',
                body:
                    'Questions can be sent via the Feedback / Chat option in Settings.',
                isDark: isDark,
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String body,
    required bool isDark,
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDark ? AppTheme.darkTextSecondary : AppColors.gray700,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? AppTheme.darkBorder : const Color(0xFFF3F4F6),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
