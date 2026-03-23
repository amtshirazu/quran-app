import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/selectedButton.dart';

import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../audio/presentation/state/audio_providers.dart';
import '../../../../domain/models/ayah.dart';
import '../../../../domain/models/translation.dart';





class AyahTile extends ConsumerStatefulWidget {
  const AyahTile({
    super.key,
    required this.ayah,
    required this.translation,
  });

  final Ayah ayah;
  final Translation translation;

  @override
  ConsumerState<AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends ConsumerState<AyahTile> {

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emerald600,
                  ),
                  child: Center(
                    child: Text(
                      "${widget.ayah.ayahNumber}",
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: AppSpacing.size12,
                      ),
                    ),
                  ),
                ),

                Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          LucideIcons.bookmark,
                          color: AppColors.gray400,
                          size: 18,
                        )
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          LucideIcons.share2,
                          color: AppColors.gray400,
                          size: 18,
                        )
                    ),
                    IconButton(
                        onPressed: () async {
                           final audio = ref.read(audioServiceProvider);
                           final defaultReciter = ref.read(defaultReciterProvider);
                           final selectedSurah = ref.read(selectedSurahProvider);

                           await audio.playVerse(
                             reciter: defaultReciter!,
                             surah: selectedSurah!,
                             ayah: widget.ayah.ayahNumber,
                           );
                        },
                        icon: Icon(
                          LucideIcons.volume2,
                          color: AppColors.gray400,
                          size: 18,
                        )
                    ),
                  ],
                )
              ],
            ),

            SizedBox(height: 10,),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.ayah.text,
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.gray900,
                  fontFamily: "Uthmanic",
                  fontSize: AppSpacing.size18,
                ),
                textAlign: TextAlign.right,
                softWrap: true,
              ),
            ),

            SizedBox(height: 8,),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.translation.text,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray700,
                  fontSize:  AppSpacing.size12,
                ),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
            ),

            SizedBox(height: 8,),

            Divider(
              color: AppColors.gray200,
              thickness: 1,
            ),

            SizedBox(height: 8,),

            Row(
              children: [
                Expanded(child: SelectedButton(
                    icon: LucideIcons.bookmarkCheck,
                    text: "Tafseer")
                ),
                SizedBox(width: 8,),
                Expanded(child: SelectedButton(
                    icon: LucideIcons.messageSquare,
                    text: "Reflection")
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
