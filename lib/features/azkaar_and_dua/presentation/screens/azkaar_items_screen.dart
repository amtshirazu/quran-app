import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_and_dua_provider.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/azkaar_card.dart';

class AzkarItemsScreen extends ConsumerWidget {
  final AzkarChapter chapter;
  const AzkarItemsScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider(chapter.id));

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF), // Soft background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFF009688), // Consistent Teal
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.name, // Fits your previous screen's property name
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
          child: CircularProgressIndicator(color: Color(0xFF009688)),
        ),
        error: (err, _) => const Center(child: Text('Error loading items')),
      ),
    );
  }
}
