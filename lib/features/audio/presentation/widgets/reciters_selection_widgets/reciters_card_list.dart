import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/features/audio/presentation/widgets/reciters_selection_widgets/reciter_card.dart';

import '../../state/audio_providers.dart';





class RecitersCardList extends ConsumerWidget {
  const RecitersCardList({super.key});

  
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final filteredReciters = ref.watch(filteredRecitersProvider);


    return SliverGrid.builder(
      itemCount: filteredReciters.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.83,
        ),
      itemBuilder: (context, index) {
          final reciter = filteredReciters[index];
          return ReciterCard(
              reciter: filteredReciters[index],
              onTap: () {
                ref.read(selectedReciterProvider.notifier).state = reciter;
                context.push('/audioSong');
              }
          );
        }
    );
  }
}
