import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_provider.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/azkaar/azkaar_chapter_tile.dart';

class AzkarChaptersScreen extends ConsumerWidget {
  final AzkarCategory category;
  const AzkarChaptersScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider(category.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    colors: [AppColors.deepGreen, AppColors.emerald600],
                  ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Select a specific occasion',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: chaptersAsync.when(
        data: (chapters) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return ChapterCard(
              chapter: chapter,
              index: index + 1,
              onTap: () => context.push('/azkaarItems', extra: chapter),
            );
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.emerald600),
        ),
        error: (err, _) => const Center(
          child: Text('No sub-categories found for this section'),
        ),
      ),
    );
  }
}
