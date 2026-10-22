import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart';

import '../../../../core/constants/app_spacing.dart';

class ReflectionHeader extends ConsumerWidget {
  const ReflectionHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reflectionListAsync = ref.watch(reflectionsUIProvider);
    final count = reflectionListAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkScaffold : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.deepGreen, AppColors.emerald600],
              ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                icon: const Icon(
                  LucideIcons.arrowLeft,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reflection Journal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSpacing.size16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$count reflections",
                      style: const TextStyle(
                        color: AppColors.emerald100,
                        fontSize: AppSpacing.size12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.go('/surahs'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.emerald600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 14),
                    SizedBox(width: 4), // Adjust gap here (e.g. 4 or 6)
                    Text("New", style: TextStyle(fontSize: AppSpacing.size10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : Colors.white30,
              ),
            ),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              onChanged: (value) {
                ref.read(reflectionSearchQueryProvider.notifier).state = value;
              },
              style: TextStyle(color: isDark ? Colors.white : Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Search reflections...",
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.darkTextSecondary : Colors.white70,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: isDark ? AppTheme.darkTextSecondary : Colors.white70,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
