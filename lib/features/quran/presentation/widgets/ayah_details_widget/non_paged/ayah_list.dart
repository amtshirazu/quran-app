import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/ayah_tile.dart';

class AyahList extends ConsumerWidget {
  const AyahList({
    super.key,
    required this.ayahkeys,
    required this.onListBuilt,
  });

  final Map<int, GlobalKey> ayahkeys;
  final VoidCallback onListBuilt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurah = ref.watch(selectedSurahProvider);

    if (selectedSurah == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => onListBuilt());

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final ayahNumber = index + 1;

        final itemKey = ayahkeys.putIfAbsent(ayahNumber, () => GlobalKey());

        return AyahTile(
          key: itemKey,
          surahNumber: selectedSurah.number,
          ayahNumber: ayahNumber,
        );
      }, childCount: selectedSurah.totalAyahs),
    );
  }
}
