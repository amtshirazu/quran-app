import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_provider.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/widgets/azkaar/azkaar_chapter_tile.dart';

class AzkarChaptersScreen extends ConsumerWidget {
  final AzkarCategory category;
  const AzkarChaptersScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: ensure your provider uses category.id correctly
    final chaptersAsync = ref.watch(chaptersProvider(category.id));

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFF009688),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name, // Fits your previous screen's property name
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                'Select a specific occasion',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      body: chaptersAsync.when(
        data: (chapters) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
          child: CircularProgressIndicator(color: Color(0xFF009688)),
        ),
        error: (err, _) => const Center(
          child: Text('No sub-categories found for this section'),
        ),
      ),
    );
  }
}
