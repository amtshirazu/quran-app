import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import '../state/guidance_provider.dart';
import 'guidance_verse_card.dart';

class GuidanceVersesList extends ConsumerWidget {
  final String emotion;

  const GuidanceVersesList({
    super.key,
    required this.emotion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versesAsync = ref.watch(guidanceVersesProvider(emotion));

    return versesAsync.when(
      data: (verses) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Section Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Verses for You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ),

            /// Verses List
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: verses.length,
              itemBuilder: (context, index) {
                return GuidanceVerseCard(verse: verses[index]);
              },
            ),

            /// "May Allah ease your heart" Call to Action Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.emerald500,
                    AppColors.emerald600,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald500.withAlpha(76),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(
                    LucideIcons.heart,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'May Allah ease your heart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Remember, Allah is always with you. Take time to reflect on these verses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },

      loading: () => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
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
            'Error loading verses: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
