 import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class AboutTermsScreen extends StatelessWidget {
  const AboutTermsScreen({super.key});

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
                    'Terms of Use',
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
                title: '1. Acceptance of Terms',
                body:
                    'By using Bayyinah Flow, you agree to these Terms of Use.',
                isDark: isDark,
              ),
              _buildSection(
                title: '2. Purpose of the App',
                body:
                    'The app is provided for personal, non-commercial reading, listening, and study of the Quran, azkar, and supplications.',
                isDark: isDark,
              ),
              _buildSection(
                title: '3. Third-Party Content',
                body:
                    'Quran text, translations, tafsirs, and audio are sourced from and streamed via third-party providers, including the Quranic Universal Library, mp3Quran.net, and EveryAyah.com. Availability of streamed content depends on these providers and is not guaranteed.',
                isDark: isDark,
              ),
              _buildSection(
                title: '4. Content Accuracy',
                body:
                    'While content is drawn from recognized sources, we recommend consulting qualified scholars for matters of religious rulings or interpretation.',
                isDark: isDark,
              ),
              _buildSection(
                title: '5. Changes to These Terms',
                body:
                    'We may update these Terms periodically. Continued use of the app constitutes acceptance of any changes.',
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
