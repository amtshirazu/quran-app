import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_provider.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/azkaar/azkaar_card.dart';

class AzkarItemsScreen extends ConsumerWidget {
  final AzkarChapter chapter;
  const AzkarItemsScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider(chapter.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: isDark
              ? AppTheme.darkScaffold
              : AppColors.emerald600,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'Read and reflect',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      body: itemsAsync.when(
        data: (items) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return AzkarItemCard(item: item);
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.emerald600),
        ),
        error: (err, _) => const Center(child: Text('Error loading items')),
      ),
    );
  }
}
