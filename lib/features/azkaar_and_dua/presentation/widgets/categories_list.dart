import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_and_dua_provider.dart';

class CategoryListCard extends ConsumerWidget {
  final AzkarCategory category;
  const CategoryListCard({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(categoryItemCountProvider(category.id));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF009688).withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFB2DFDB),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            '${category.id}',
            style: const TextStyle(
              color: Color(0xFF00796B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: countAsync.when(
          data: (count) => Text(
            '$count azkar',
            style: const TextStyle(color: Color(0xFF009688), fontSize: 13),
          ),
          loading: () => const Text('...', style: TextStyle(fontSize: 13)),
          error: (_, __) => const Text('0 azkar'),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF009688),
        ),
        onTap: () {
          context.push('/azkaarChapters', extra: category);
        },
      ),
    );
  }
}
