import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_spacing.dart';
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
            fontSize: AppSpacing.size15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2E3A),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          isWitr
              ? "Special supplications for Witr prayer and Qunoot"
              : "Essential supplications from the Holy Quran",
          style: const TextStyle(fontSize: AppSpacing.size12, color: Colors.black54),
        ),
      ],
    );
  }
}
