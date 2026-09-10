import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class AboutCreditsScreen extends StatelessWidget {
  const AboutCreditsScreen({super.key});

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
                    'Credits',
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
            /// TRANSLATION, TAFSIR & FONTS
            _buildSectionTitle('TRANSLATION, TAFSIR & FONTS', isDark),
            _buildItemCard(
              title: 'Quranic Universal Library (QUL)',
              subtitle: 'Translations, tafsirs, and Arabic fonts ',
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            /// AUDIO
            _buildSectionTitle('AUDIO', isDark),
            _buildItemCard(
              title: 'mp3Quran.net',
              subtitle: 'Full surah audio streaming',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'EveryAyah.com',
              subtitle: 'Ayah-by-ayah audio streaming',
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            /// AZKAR & SUPPLICATIONS
            _buildSectionTitle('AZKAR & SUPPLICATIONS', isDark),
            _buildItemCard(
              title: 'Hisnul Muslim (Fortress of the Muslim)',
              subtitle: 'Daily azkar content, via the muslim_data_flutter library',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildItemCard(
              title: 'Selected Invocations',
              subtitle:
                  'Compiled by Muhammad bin Abdul-Aziz Al-Musnad — source for Witr and Qunoot supplications',
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            /// VERSES FOR YOUR MOOD
            _buildSectionTitle('VERSES FOR YOUR MOOD', isDark),
            _buildTextCard(
              text:
                  'An original feature of Bayyinah Flow. Verses were grouped by mood and paired with reflection notes, organized with AI assistance.',
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            /// COMPILATION NOTE
            _buildSectionTitle('COMPILATION NOTE', isDark),
            _buildTextCard(
              text:
                  'Dua content in this app was compiled from the sources above and organized with AI assistance.',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkCategoryTitle : AppColors.emerald600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard({
    required String text,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppColors.gray200,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: isDark ? AppTheme.darkTextSecondary : AppColors.gray700,
        ),
      ),
    );
  }
}
