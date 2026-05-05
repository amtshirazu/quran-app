import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart';
import 'package:quran_app/features/reflection/presentation/widgets/reflection_card.dart';
import 'package:quran_app/features/reflection/presentation/widgets/empty_reflection_card.dart';
import 'package:quran_app/features/reflection/presentation/widgets/reflection_journey.dart';
import 'package:quran_app/features/reflection/presentation/widgets/reflection_stats_card.dart';

class ReflectionBody extends ConsumerWidget {
  const ReflectionBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered reflections (handles search automatically)
    final reflectionsAsync = ref.watch(reflectionsUIProvider);
    final filteredReflections = ref.watch(filteredReflectionsProvider);

    return reflectionsAsync.when(
      data: (allReflections) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1st - Reflection Journey (Constant)
            const ReflectionJourneyCard(),

            const SizedBox(height: 24),

            // 2nd - Reflections Logic
            if (allReflections.isEmpty)
              const EmptyReflectionsCard()
            else if (filteredReflections.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: EmptyReflectionsCard(),
                ),
              )
            else
              Column(
                children: filteredReflections.map((reflection) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ReflectionCard(reflection),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // 3rd - Reflection Stats Card
            ReflectionStatsCard(),

            // Extra bottom padding for better scrolling
            const SizedBox(height: 40),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
    );
  }
}
