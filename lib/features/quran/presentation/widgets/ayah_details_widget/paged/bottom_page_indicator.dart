import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

class BottomPageIndicator extends ConsumerWidget {
  const BottomPageIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 10),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: Color(0xFFCCCCCC), thickness: 1),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            child: Text(
              "$currentPage",

              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,

                color: const Color(0xFF666666),
              ),
            ),
          ),

          const Expanded(
            child: Divider(color: Color(0xFFCCCCCC), thickness: 1),
          ),
        ],
      ),
    );
  }
}
