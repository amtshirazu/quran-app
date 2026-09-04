import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import '../../states/dua_provider.dart';

class DuaCategoryToggle extends ConsumerWidget {
  const DuaCategoryToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedDuaCategoryProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context: context,
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
            child: _buildTabButton(
              context: context,
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

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.emerald600 : Colors.transparent,
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
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.gray700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
