import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/bookmark_tabs.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/delete_bookmark.dart';

import '../../../../core/constants/app_spacing.dart';

class BookmarkHeader extends ConsumerWidget {
  const BookmarkHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCount = ref.watch(totalCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
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
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20,),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bookmarks",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSpacing.size16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$totalCount saved",
                      style: const TextStyle(
                          color: AppColors.emerald100,
                          fontSize: AppSpacing.size12,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => handleDeleteAction(context, ref),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.trash2, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Delete All",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSpacing.size12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const BookmarkTabs(),
        ],
      ),
    );
  }
}
