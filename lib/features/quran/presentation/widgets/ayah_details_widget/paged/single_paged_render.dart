import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../domain/models/paged.dart';
import '../../../state/quran_providers.dart';
import 'polygon_utils.dart';
import 'ayah_highlight_painter.dart';

class QuranPage extends ConsumerWidget {
  final String svgAsset;
  final List<PagedAyah> ayahs;
  final Function(PagedAyah) onTapAyah;

  const QuranPage({
    super.key,
    required this.svgAsset,
    required this.ayahs,
    required this.onTapAyah,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ayahs.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxDesignX = 0;
        double maxDesignY = 0;

        for (var ayah in ayahs) {
          final rect = polygonToRect(ayah.polygon);

          if (rect.right > maxDesignX) maxDesignX = rect.right;
          if (rect.bottom > maxDesignY) maxDesignY = rect.bottom;

        }

        final scaleX = constraints.maxWidth / maxDesignX;
        final scaleY = constraints.maxHeight / maxDesignY;

        final playingAyah = ref.watch(currentPlayingAyahProvider);

        return Stack(
          children: [

            SvgPicture.asset(
              svgAsset,
              fit: BoxFit.contain,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),

            ...ayahs.map((ayah) {

              final rect = polygonToRect(ayah.polygon);

              final isHighlighted = false ;

              return Positioned(
                left: rect.left * scaleX,
                top: rect.top * scaleY,
                width: rect.width * scaleX,
                height: rect.height * scaleY,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTapAyah(ayah),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isHighlighted ? Colors.yellow.withOpacity(0.35) : Colors.transparent,
                      border: Border.all(
                        color: isHighlighted ? Colors.yellow : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  )
                ),
              );
            }),
          ],
        );
      },
    );
  }
}