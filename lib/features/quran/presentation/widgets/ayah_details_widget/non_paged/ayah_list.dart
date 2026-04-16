import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/selectedButton.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../audio/presentation/state/audio_providers.dart';
import '../../../../../progress/presentation/state/progress_provider.dart';
import '../../../../domain/models/ayah.dart';
import '../../../../domain/models/translation.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/ayah_tile.dart';


class AyahList extends ConsumerStatefulWidget {
  const AyahList({
    super.key,
    required this.ayahkeys,
    required this.onListBuilt,
  });

  final Map<int, GlobalKey> ayahkeys;
  final VoidCallback onListBuilt;

  @override
  ConsumerState<AyahList> createState() => _AyahListState();
}

class _AyahListState extends ConsumerState<AyahList> {
  Map<String, dynamic>? _ayahParams;
  Map<String, dynamic>? _translationParams;
  int? _currentSurahNumber;

  void _updateParams(int surahNumber) {
    if (_currentSurahNumber == surahNumber) return;

    _currentSurahNumber = surahNumber;
    _ayahParams = {
      "surahNumber": surahNumber,
      "script": "uthmani",
    };
    _translationParams = {
      "surahNumber": surahNumber,
      "translationFile": "saheeh",
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedSurah = ref.watch(selectedSurahProvider);
    if (selectedSurah == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    _updateParams(selectedSurah.number);

    final ayahAsync = ref.watch(ayahListProvider(_ayahParams!));

    final translationAsync = ref.watch(translationListProvider(_translationParams!));

    return ayahAsync.when(
      data: (ayahs) => translationAsync.when(
        data: (translations) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onListBuilt();
          });

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                    final ayah = ayahs[index];
                  
                    final translation = translations.firstWhere(
                      (t) => t.ayahNumber == ayah.ayahNumber,
                      orElse: () => Translation(
                        surahNumber: selectedSurah.number,
                        ayahNumber: ayah.ayahNumber,
                        text: "Translation not found",
                      ),
                    );

                    final itemKey = widget.ayahkeys.putIfAbsent(
                      ayah.ayahNumber,
                      () => GlobalKey(),
                    );

                    return AyahTile(
                      key: itemKey,
                      ayah: ayah,
                      translation: translation,
                    );
                  },
               childCount: ayahs.length,
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SliverToBoxAdapter(
          child: Center(child: Text('Error loading translations: $error')),
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(child: Text('Error loading ayahs: $error')),
      ),
    );
  }
}
