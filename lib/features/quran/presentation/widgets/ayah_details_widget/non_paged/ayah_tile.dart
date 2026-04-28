import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/bookmark_note_dialog.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/selectedButton.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../audio/presentation/state/audio_providers.dart';
import '../../../../../progress/presentation/state/progress_provider.dart';
import '../../../../domain/models/ayah.dart';
import '../../../../domain/models/translation.dart';

class AyahTile extends ConsumerStatefulWidget {
  const AyahTile({super.key, required this.ayah, required this.translation});

  final Ayah ayah;
  final Translation translation;

  @override
  ConsumerState<AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends ConsumerState<AyahTile> {
  bool _hasBeenTracked = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final selectedSurah = ref.watch(selectedSurahProvider);

    if (selectedSurah == null) {
      return const SizedBox.shrink();
    }

    final isBookmarked = ref.watch(
      isAyahBookmarkedProvider((
        surahId: selectedSurah.number,
        ayahNumber: widget.ayah.ayahNumber,
      )),
    );

    return VisibilityDetector(
      key: Key('visibility-${widget.ayah.ayahNumber}'),
      onVisibilityChanged: (visibilityInfo) async {
        if (visibilityInfo.visibleFraction >= 0.6 && !_hasBeenTracked) {
          final progressService = ref.read(progressServiceProvider);
          final selectedSurah = ref.read(selectedSurahProvider);

          if (selectedSurah == null) return;

          await progressService.trackAyah(
            selectedSurah.number,
            widget.ayah.ayahNumber,
          );

          ref.invalidate(lastReadProvider);

          if (mounted) {
            setState(() {
              _hasBeenTracked = true;
            });
          }
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
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

                  const Spacer(),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final selectedSurah = ref.read(selectedSurahProvider);
                          if (selectedSurah == null) return;

                          // 👇 STEP 1: fetch bookmarks
                          final bookmarks = await ref.read(
                            bookmarksProvider.future,
                          );

                          Bookmark? existingBookmark;

                          try {
                            existingBookmark = bookmarks.firstWhere(
                              (b) =>
                                  b.type == BookmarkType.verse &&
                                  b.surahId == selectedSurah.number &&
                                  b.ayahNumber == widget.ayah.ayahNumber,
                            );
                          } catch (_) {
                            existingBookmark = null;
                          }

                          // open dialog with existing note
                          final note = await showBookmarkDialog(
                            context,
                            title: "Add Bookmark",
                            subtitle:
                                "${selectedSurah.nameEnglish} • Verse ${widget.ayah.ayahNumber}",
                            initialNote: existingBookmark?.note,
                          );

                          if (note == null) return;

                          // save (insert or update)
                          final service = ref.read(bookmarkServiceProvider);

                          await service.addOrUpdateVerseBookmark(
                            surahId: selectedSurah.number,
                            ayahNumber: widget.ayah.ayahNumber,
                            note: note,
                          );

                          ref.invalidate(bookmarksProvider);
                        },
                        icon: Icon(
                          isBookmarked
                              ? LucideIcons.bookmarkCheck
                              : LucideIcons.bookmark,
                          color: isBookmarked
                              ? Colors
                                    .amber // yellow
                              : AppColors.gray400,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          LucideIcons.share2,
                          color: AppColors.gray400,
                          size: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final audio = ref.read(audioServiceProvider);
                          final defaultReciter = ref.read(
                            defaultReciterProvider,
                          );
                          final selectedSurah = ref.read(selectedSurahProvider);

                          if (defaultReciter == null || selectedSurah == null) {
                            return;
                          }

                          await audio.playVerse(
                            reciter: defaultReciter,
                            surah: selectedSurah,
                            ayah: widget.ayah.ayahNumber,
                          );
                        },
                        icon: const Icon(
                          LucideIcons.volume2,
                          color: AppColors.gray400,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

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

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.translation.text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray700,
                    fontSize: AppSpacing.size12,
                  ),
                  textAlign: TextAlign.left,
                  softWrap: true,
                ),
              ),

              const SizedBox(height: 8),

              const Divider(color: AppColors.gray200, thickness: 1),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: SelectedButton(
                      icon: LucideIcons.bookmarkCheck,
                      text: "Tafseer",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectedButton(
                      icon: LucideIcons.messageSquare,
                      text: "Reflection",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
