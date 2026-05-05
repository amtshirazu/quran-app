import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart';

class ReflectionHeader extends ConsumerWidget {
  const ReflectionHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stats or list length for the "X reflections" subtitle
    final reflectionListAsync = ref.watch(reflectionsUIProvider);
    final count = reflectionListAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
      ),
      child: Column(
        children: [
          // Top Row: Back, Title/Count, and New Button
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reflection Journal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$count reflections",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // "+ New" Button
              ElevatedButton.icon(
                onPressed: () => context.go('/surahs'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD97706),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search Bar
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextField(
              onChanged: (value) {
                ref.read(reflectionSearchQueryProvider.notifier).state = value;
              },
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: "Search reflections...",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: Colors.white70,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
