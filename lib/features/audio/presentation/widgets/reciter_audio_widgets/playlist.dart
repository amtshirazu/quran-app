import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/audio/presentation/widgets/reciter_audio_widgets/playlist_card.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../quran/presentation/state/quran_providers.dart';
import '../../state/audio_providers.dart';

class Playlist extends ConsumerWidget {
  const Playlist({super.key, });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final surahsAsync = ref.watch(surahListProvider);

    return sliverAdapter(
      child: Card(
        margin: const EdgeInsets.only(right: 16, left: 16, bottom: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 3,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.all(25),
              child: const Text(
                "Playlist",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),


            surahsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),

              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text("Error: $e")),
              ),

              data: (surahs) => Container(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),

                child: PlaylistCard(surahs: surahs)
              ),
            ),

            Container(
              padding: const EdgeInsets.all(15),
            ),
          ],
        ),
      ),
    );
  }


  SliverToBoxAdapter sliverAdapter({required Widget child}) {
    return SliverToBoxAdapter(child: child);
  }
}