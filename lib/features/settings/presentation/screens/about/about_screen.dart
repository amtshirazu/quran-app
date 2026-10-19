import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : AppTheme.lightScaffold,
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
              padding: const EdgeInsets.fromLTRB(4, 10, 16, 16),
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
                        context.go('/settings');
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.size16,
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.emerald600.withAlpha(38)
                          : AppColors.emerald100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      LucideIcons.bookOpen,
                      color: AppColors.emerald600,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            /// App Name & Version
            Text(
              'Bayyinah Flow',
              style: TextStyle(
                fontSize: AppSpacing.size18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.1.0',
              style: TextStyle(
                fontSize: AppSpacing.size12,
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
                  fontSize: AppSpacing.size13,
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
                        fontSize: AppSpacing.size12,
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
            Material(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                ),
              ),
              clipBehavior: Clip.antiAlias,
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
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// Developer / Branding Footer
            Text(
              'DEVELOPER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.darkTextSecondary.withAlpha(140)
                    : AppColors.gray400,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/logo/amtilyst.jpg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        LucideIcons.code,
                        size: 14,
                        color:
                        isDark ? AppColors.emerald600 : AppColors.gray600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AMTILYST',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: AppSpacing.size14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                  ),
                ),
              ],
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
          fontSize: AppSpacing.size14,
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