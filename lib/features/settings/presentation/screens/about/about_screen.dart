import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                        context.go('/settings');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'About',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// App Launcher Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/app_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            /// App Name & Version
            Text(
              'Bayyinah Flow',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 2.1.0',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppColors.gray500,
              ),
            ),
            const SizedBox(height: 14),

            /// App Tagline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'A calm, focused space to read, listen to, and understand the Quran.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// Trusted Review Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.emerald600.withAlpha(38)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.emerald600,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Content reviewed with trusted translations and scholarly references.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.emerald600 : const Color(0xFF00695C),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            /// Sub-Navigation Menu
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                ),
              ),
              child: Column(
                children: [
                  _buildNavTile(
                    context,
                    title: 'Credits',
                    route: '/aboutCredits',
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildNavTile(
                    context,
                    title: 'Terms of Use',
                    route: '/aboutTerms',
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildNavTile(
                    context,
                    title: 'Privacy Policy',
                    route: '/aboutPrivacy',
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildNavTile(
                    context,
                    title: 'Open-source licenses',
                    route: '/aboutLicenses',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            /// Footer
            Text(
              'Made with care by',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : AppColors.gray500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Abdullah',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required String title,
    required String route,
    required bool isDark,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.gray400,
        size: 20,
      ),
      onTap: () => context.push(route),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppTheme.darkBorder : const Color(0xFFF3F4F6),
      indent: 16,
      endIndent: 16,
    );
  }
}
