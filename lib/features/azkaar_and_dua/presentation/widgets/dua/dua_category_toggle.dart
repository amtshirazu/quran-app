import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../states/dua_provider.dart';

class DuaCategoryToggle extends ConsumerWidget {
  const DuaCategoryToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedDuaCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFE8F3EE),
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: _DuaTabButton(
              label: 'Quranic Duas',
              icon: LucideIcons.bookOpen,
              isSelected: selectedCategory == DuaCategory.quranic,
              onTap: () {
                ref.read(selectedDuaCategoryProvider.notifier).state =
                    DuaCategory.quranic;
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _DuaTabButton(
              label: 'Witr & Qunoot',
              icon: LucideIcons.sparkles,
              isSelected: selectedCategory == DuaCategory.witr,
              onTap: () {
                ref.read(selectedDuaCategoryProvider.notifier).state =
                    DuaCategory.witr;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DuaTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final targetContentColor = isSelected
        ? Colors.white
        : (isDark ? AppTheme.darkTextSecondary : AppColors.gray700);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.emerald600
              : (isDark ? AppTheme.darkScaffold : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emerald600.withAlpha(51),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: targetContentColor),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                fontSize: AppSpacing.size12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: targetContentColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
