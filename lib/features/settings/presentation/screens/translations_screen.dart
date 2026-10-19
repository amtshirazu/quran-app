import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/quran/presentation/state/translation_provider.dart';
import 'package:quran_app/features/settings/domain/model/translation_model.dart';

import '../../../../core/constants/app_spacing.dart';

class TranslationsScreen extends ConsumerStatefulWidget {
  const TranslationsScreen({super.key});

  @override
  ConsumerState<TranslationsScreen> createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends ConsumerState<TranslationsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeDbNames = ref.watch(selectedTranslationsProvider);

    final filteredList = kAllTranslations.where((t) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return t.name.toLowerCase().contains(query) ||
          t.language.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : AppTheme.lightScaffold,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
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
              child: Column(
                children: [
                  Row(
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
                            context.go('/');
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Translations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSpacing.size16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// Search Bar with Vertically Centered Text
                  Container(
                    margin: const EdgeInsets.only(left: 24, right: 16),
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
                    ),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.gray900,
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Search translations',
                        hintStyle: TextStyle(
                          color: AppColors.gray400,
                          fontSize: AppSpacing.size10,
                        ),
                        // Removes default 48x48 constraint
                        prefixIconConstraints: BoxConstraints(),
                        // Custom padding lets you tune the exact gap to the text
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 6.0),
                          child: Icon(
                            LucideIcons.search,
                            color: AppColors.gray400,
                            size: 14,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          /// Active Count Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: isDark
                ? AppTheme.darkSurface
                : const Color(0xFFE8F5E9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${activeDbNames.length} ACTIVE',
                  style: const TextStyle(
                    fontSize: AppSpacing.size10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emerald600,
                    letterSpacing: 0.8,
                  ),
                ),
                const Row(
                  children: [
                    Icon(
                      LucideIcons.star,
                      size: 14,
                      color: AppColors.emerald600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Default translation',
                      style: TextStyle(
                        fontSize: AppSpacing.size10,
                        color: AppColors.emerald600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Translation Items List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final isSelected = activeDbNames.contains(item.dbFileName);

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.emerald600
                          : (isDark ? AppTheme.darkBorder : AppColors.gray200),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (item.isDefault) return;
                        ref
                            .read(selectedTranslationsProvider.notifier)
                            .toggleTranslation(item.dbFileName);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Checkbox Icon
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                isSelected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: isSelected
                                    ? AppColors.emerald600
                                    : AppColors.gray400,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            /// Translation Title & Language Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: AppSpacing.size13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppTheme.darkTextPrimary
                                          : AppColors.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        item.language,
                                        style: TextStyle(
                                          fontSize: AppSpacing.size12,
                                          color: isDark
                                              ? AppTheme.darkTextSecondary
                                              : AppColors.gray600,
                                        ),
                                      ),
                                      if (item.isDefault) ...[
                                        const Text(
                                          ' • Default',
                                          style: TextStyle(
                                            fontSize: AppSpacing.size12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.emerald600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
