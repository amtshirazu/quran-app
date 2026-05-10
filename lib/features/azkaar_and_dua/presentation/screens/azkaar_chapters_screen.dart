import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_and_dua_provider.dart';

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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AzkarItemsScreen(chapter: chapter),
                ),
              ),
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

// --- CHAPTER ITEM WIDGET ---
class ChapterCard extends StatelessWidget {
  final AzkarChapter chapter;
  final int index;
  final VoidCallback onTap;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        // Subtle dot or number to keep it organized
        leading: Text(
          index.toString().padLeft(2, '0'),
          style: TextStyle(
            color: Colors.teal.withOpacity(0.3),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        title: Text(
          chapter.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3436),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Color(0xFF009688),
        ),
        onTap: onTap,
      ),
    );
  }
}
