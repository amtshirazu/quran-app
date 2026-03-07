import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/app_colors.dart';
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
      color: Theme.of(context).scaffoldBackgroundColor,
      height: 100,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final audioProvider = ref.read(audioServiceProvider);
              audioProvider.stop();
              ref.read(selectedReciterProvider.notifier).state = null;
              ref.read(selectedSurahIndexProvider.notifier).state = 0;
              context.pop();
            },
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          const SizedBox(width: 8),


         Stack(
              clipBehavior: Clip.none,
              children: [

                Text(
                  selectedReciter.name,
                  style: const TextStyle(
                    fontSize: 20,
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
                      fontSize: 18,
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