import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../domain/models/Reciters.dart';
import '../../state/audio_providers.dart';

class ReciterHeader extends ConsumerWidget {
  const ReciterHeader({super.key, required this.reciter});

  final Reciter reciter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(selectedReciterProvider);

    if (selectedReciter == null) return const SizedBox.shrink();

    return Container(
      color: AppColors.emerald500,
      height: 160,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final audioProvider = ref.read(audioServiceProvider);

              audioProvider.setUserSelecting(true);

               await audioProvider.reset();

              ref.read(selectedReciterProvider.notifier).state = null;

              context.go('/audioHome');
            },
            icon: Icon(
              LucideIcons.arrowLeft,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),


         Stack(
              clipBehavior: Clip.none,
              children: [

                Text(
                  selectedReciter.name,
                  style: const TextStyle(
                    fontSize: AppSpacing.size18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),


                Positioned(
                  top: 30,
                  right: 0,
                  child: Text(
                    selectedReciter.arabicName,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: AppSpacing.size14,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}