import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/bookmark_tabs.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/delete_bookmark.dart';

class BookmarkHeader extends ConsumerWidget {
  const BookmarkHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCount = ref.watch(totalCountProvider);

    return Container(
      color: const Color(0xFFD97706),
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$totalCount saved",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () =>
                    handleDeleteAction(context, ref), // Logic called here
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Delete All",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Adjusted for better fit
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
