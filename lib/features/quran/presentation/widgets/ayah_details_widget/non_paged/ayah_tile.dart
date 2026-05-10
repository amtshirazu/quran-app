import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/bookmark_note_dialog.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/translation_provider.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/selectedButton.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart';
import 'package:quran_app/features/reflection/presentation/widgets/reflection_note_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../audio/presentation/state/audio_providers.dart';
import '../../../../../progress/presentation/state/last_read_provider.dart';
import 'package:quran/quran.dart' as quran;

class AyahTile extends ConsumerStatefulWidget {
  const AyahTile({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  ConsumerState<AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends ConsumerState<AyahTile> {
  bool _hasBeenTracked = false;

  Future<void> _handleReflectionTap() async {
    final selectedSurah = ref.read(selectedSurahProvider);
    if (selectedSurah == null) return;

    // Check for existing reflection
    final reflections = await ref.read(reflectionsProvider.future);
    String? existingContent;

    try {
      final existing = reflections.firstWhere(
        (r) =>
            r['surah_id'] == selectedSurah.number &&
            r['ayah_number'] == widget.ayahNumber,
      );
      existingContent = existing['content'];
    } catch (_) {
      existingContent = null;
    }

    if (!mounted) return;

    // Show Reflection Dialog
    final content = await showReflectionDialog(
      context,
      surahName: selectedSurah.nameEnglish,
      ayahNumber: widget.ayahNumber,
      initialReflection: existingContent,
    );

    if (content == null) return;

    // Save to Database
    final reflectionService = ref.read(reflectionServiceProvider);
    await reflectionService.addOrUpdateReflection(
      surahId: selectedSurah.number,
      ayahNumber: widget.ayahNumber,
      content: content,
    );

    // Refresh UI and Stats
    ref.invalidate(reflectionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedSurah = ref.watch(selectedSurahProvider);
    if (selectedSurah == null) return const SizedBox.shrink();

    // Fetch Ayah Text
    String ayahText = quran.getVerse(
      widget.surahNumber,
      widget.ayahNumber,
      verseEndSymbol: false,
    );
    // Fetch translation using Riverpod provider
    Widget translationWidget = ref
        .watch(
          translationProvider((
            surah: widget.surahNumber,
            verse: widget.ayahNumber,
          )),
        )
        .when(
          data: (data) => Text(
            data,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.gray700,
              fontSize: AppSpacing.size12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.left,
          ),
          loading: () => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    // last line shorter for a natural "paragraph" look
                    width: index == 2 ? 150 : double.infinity,
                    height: 12.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          error: (err, stack) => const Text(
            "Translation unavailable",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        );

    final isBookmarked = ref.watch(
      isAyahBookmarkedProvider((
        surahId: selectedSurah.number,
        ayahNumber: widget.ayahNumber,
      )),
    );

    return VisibilityDetector(
      key: Key('visibility-${widget.ayahNumber}'),
      onVisibilityChanged: (visibilityInfo) async {
        if (visibilityInfo.visibleFraction >= 0.6 && !_hasBeenTracked) {
          final progressService = ref.read(progressServiceProvider);
          await progressService.trackAyah(
            selectedSurah.number,
            widget.ayahNumber,
          );
          ref.invalidate(lastReadProvider);
          if (mounted) setState(() => _hasBeenTracked = true);
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        color: Colors.white,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                        "${widget.ayahNumber}",
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
                          final bookmarks = await ref.read(
                            bookmarksProvider.future,
                          );
                          Bookmark? existing;
                          try {
                            existing = bookmarks.firstWhere(
                              (b) =>
                                  b.type == BookmarkType.verse &&
                                  b.surahId == selectedSurah.number &&
                                  b.ayahNumber == widget.ayahNumber,
                            );
                          } catch (_) {}

                          if (!mounted) return;
                          final note = await showBookmarkDialog(
                            context,
                            title: "Add Bookmark",
                            subtitle:
                                "${selectedSurah.nameEnglish} • Verse ${widget.ayahNumber}",
                            initialNote: existing?.note,
                            isPageMode: false,
                          );

                          if (note == null) return;
                          await ref
                              .read(bookmarkServiceProvider)
                              .addOrUpdateVerseBookmark(
                                surahId: selectedSurah.number,
                                ayahNumber: widget.ayahNumber,
                                note: note,
                              );
                          ref.invalidate(bookmarksProvider);
                        },
                        icon: Icon(
                          isBookmarked
                              ? LucideIcons.bookmarkCheck
                              : LucideIcons.bookmark,
                          color: isBookmarked
                              ? Colors.amber
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
                          if (defaultReciter == null) return;
                          await audio.playVerse(
                            reciter: defaultReciter,
                            surah: selectedSurah,
                            ayah: widget.ayahNumber,
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
                  ayahText,
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppColors.gray900,
                    fontFamily: "Uthmanic",
                    fontSize: AppSpacing.size18,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: translationWidget),
              const SizedBox(height: 8),
              const Divider(color: AppColors.gray200, thickness: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SelectedButton(
                      icon: LucideIcons.bookmarkCheck,
                      text: "Tafseer",
                      onTap: () {
                        // Logic for Tafseer
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectedButton(
                      icon: LucideIcons.messageSquare,
                      text: "Reflection",
                      onTap: _handleReflectionTap, // Integrated logic
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
