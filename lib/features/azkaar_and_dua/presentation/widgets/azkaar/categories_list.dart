import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_provider.dart';

class CategoryListCard extends ConsumerWidget {
  final AzkarCategory category;
  const CategoryListCard({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(categoryItemCountProvider(category.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isDark
            ? AppTheme.darkSurface
            : const Color(0xFFE0F2F1).withAlpha(102),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark
                ? AppTheme.darkBorder
                : AppColors.emerald600.withAlpha(26),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.emerald600.withAlpha(38)
                  : const Color(0xFFB2DFDB),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${category.id}',
              style: TextStyle(
                color: isDark ? AppColors.emerald600 : const Color(0xFF00796B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          title: Text(
            category.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
            ),
          ),
          subtitle: countAsync.when(
            data: (count) => Text(
              '$count azkar',
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppColors.emerald600,
                fontSize: 11,
              ),
            ),
            loading: () => const Text('...', style: TextStyle(fontSize: 11)),
            error: (_, __) => const Text('0 azkar'),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.emerald600,
          ),
          onTap: () {
            context.push('/azkaarChapters', extra: category);
          },
        ),
      ),
    );
  }
}
