import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_and_dua_provider.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/categories_list.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/prophetic_tip_card.dart';

class AzkarCategoriesScreen extends ConsumerWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFF009688),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Azkar Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Daily remembrance from the Sunnah',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: categories.length + 1, // +1 for the Tip Card at the bottom
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return const PropheticTipCard();
            }
            return CategoryListCard(category: categories[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
