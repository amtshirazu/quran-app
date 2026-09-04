import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import '../state/guidance_provider.dart';
import 'guidance_feeling_card.dart';

class GuidanceFeelingsList extends ConsumerWidget {
  const GuidanceFeelingsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(guidanceCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GuidanceFeelingCard(
              category: category,
              onTap: () {
                ref.read(selectedEmotionProvider.notifier).state =
                    category.emotion;
              },
            );
          },
        );
      },
      loading: () => SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.emerald600,
          ),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading categories: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
