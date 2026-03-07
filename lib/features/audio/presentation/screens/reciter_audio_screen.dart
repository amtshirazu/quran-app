import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/audio_providers.dart';
import '../widgets/reciter_audio_widgets/player_card.dart';
import '../widgets/reciter_audio_widgets/playlist.dart';
import '../widgets/reciter_audio_widgets/reciter_header.dart';


class ReciterAudioScreen extends ConsumerWidget {
  const ReciterAudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(selectedReciterProvider);

    if (selectedReciter == null) {
      return const Scaffold(
        body: Center(child: Text("No reciter selected")),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: CustomScrollView(
            slivers: [

              SliverToBoxAdapter(
                child: ReciterHeader(reciter: selectedReciter),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 25,),
              ),

              const SliverToBoxAdapter(
                child: PlayerCard(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 25,),
              ),

              Playlist(),
            ],
          ),
        ),
      ),
    );
  }
}


