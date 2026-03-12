import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';
import '../../../../../../core/widgets/Loading.dart';
import '../../../state/quran_providers.dart';
import 'ayah_tile.dart';






class AyahList extends ConsumerWidget {
  const AyahList({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final ayahParams = ref.watch(ayahParamsProvider);
    final translationParams = ref.watch(translationParamsProvider);

    if (ayahParams == null || translationParams == null) {
      return const SliverToBoxAdapter(
        child: SizedBox(
            height: 200,
            child: Center(
                child: Text("No surah selected")
            ),
        ),
      );
    }

    final ayahAsync = ref.watch(ayahListProvider(ayahParams));
    final translationAsync = ref.watch(translationListProvider(translationParams));

    return ayahAsync.when(
        loading: () => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: LoadingWidget(),
          ),
        ),

        error: (err, stack) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(child: Text('Error: $err')),
          ),
        ),

       data: (ayahs) {
         return translationAsync.when(
           loading: () => SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.all(40.0),
               child: LoadingWidget(),
             ),
           ),

           error: (err, stack) => SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.all(20.0),
               child: Center(child: Text('Error: $err')),
             ),
           ),

           data: (translation) {
             return SliverList(
               delegate: SliverChildBuilderDelegate(
                     (context, index) {
                     return Padding(
                       padding: EdgeInsets.symmetric(horizontal: 15,),
                       child: AyahTile(
                         ayah: ayahs[index],
                         translation: translation[index],
                       ),
                     );
                   },
                 childCount: ayahs.length,
                 addAutomaticKeepAlives: false,
                 addRepaintBoundaries: true,
               ),
             );
           }
         );
       }
    );
  }
}
