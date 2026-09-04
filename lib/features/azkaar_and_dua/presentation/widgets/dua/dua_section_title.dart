import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/dua_provider.dart';

class DuaSectionTitle extends ConsumerWidget {
  const DuaSectionTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(selectedDuaCategoryProvider);
    final isWitr = category == DuaCategory.witr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isWitr ? "Witr & Qunoot Duas" : "Quranic Duas",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2E3A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isWitr
              ? "Special supplications for Witr prayer and Qunoot"
              : "Essential supplications from the Holy Quran",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}
