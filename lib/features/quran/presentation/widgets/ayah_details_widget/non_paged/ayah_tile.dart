import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/bookmark_note_dialog.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/translation_provider.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/selectedButton.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/tafseer_bottom_sheet.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart';
import 'package:quran_app/features/reflection/presentation/widgets/reflection_note_dialog.dart';
import 'package:quran_app/features/settings/presentation/state/display_settings_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  Timer? _visibilityTimer;
  bool _hasBeenTracked = false;
  static const Duration _ayahDwellThreshold = Duration(seconds: 2);

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleReflectionTap() async {
    if (!mounted) return;
    final selectedSurah = ref.read(selectedSurahProvider);
    if (selectedSurah == null) return;

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

    final content = await showReflectionDialog(
      context,
      surahName: selectedSurah.nameEnglish,
      ayahNumber: widget.ayahNumber,
      initialReflection: existingContent,
    );

    if (content == null || !mounted) return;

    final reflectionService = ref.read(reflectionServiceProvider);
    await reflectionService.addOrUpdateReflection(
      surahId: selectedSurah.number,
      ayahNumber: widget.ayahNumber,
      content: content,
    );

    if (!mounted) return;
    ref.invalidate(reflectionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedSurah = ref.watch(selectedSurahProvider);
    if (selectedSurah == null) return const SizedBox.shrink();

    final quranScript = ref.watch(quranScriptProvider);
    final ayahTextSize = ref.watch(ayahTextSizeProvider);
    final translationTextSize = ref.watch(translationTextSizeProvider);
    final showAyahBefore = ref.watch(showAyahBeforeTranslationProvider);

    final fontName = quranScript == 'IndoPak' ? "Indo Park" : "Uthmanic";

    final playingAyah = ref.watch(currentPlayingAyahProvider);
    final isHighlightEnabled = ref.watch(highlightActiveVerseProvider);
    final isCurrentlyPlaying =
        isHighlightEnabled &&
        playingAyah?.surah == selectedSurah.number &&
        playingAyah?.ayah == widget.ayahNumber;

    // Fetch Ayah Text
    String ayahText = quran.getVerse(
      widget.surahNumber,
      widget.ayahNumber,
      verseEndSymbol: false,
    );

    // Fetch active translations using Riverpod provider
    Widget translationWidget = ref
        .watch(
          activeVerseTranslationsProvider((
            surah: widget.surahNumber,
            verse: widget.ayahNumber,
          )),
        )
        .when(
          data: (translations) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: translations.map((t) {
              final isSecondary = !t.isDefault;
              return Padding(
                padding: EdgeInsets.only(top: isSecondary ? 10.0 : 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSecondary) ...[
                      Divider(
                        height: 16,
                        thickness: 0.8,
                        color: isDark
                            ? AppTheme.darkBorder
                            : const Color(0xFFE5E7EB),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          t.translationName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emerald600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      t.text,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppColors.gray700,
                        fontSize: translationTextSize,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              );
            }).toList(),
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

    Widget buildArabicTextWidget() {
      final arabicWidget = Text(
        ayahText,
        style: textTheme.headlineLarge?.copyWith(
          color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
          fontFamily: fontName,
          fontSize: ayahTextSize,
          height: 2.1,
        ),
        textAlign: TextAlign.right,
      );

      if (isCurrentlyPlaying) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.emerald600.withAlpha(50)
                : const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.emerald600.withAlpha(120),
              width: 1,
            ),
          ),
          child: arabicWidget,
        );
      }

      return arabicWidget;
    }

    return VisibilityDetector(
      key: Key('visibility-${widget.surahNumber}-${widget.ayahNumber}'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;

        final isAutoScrolling = ref.read(isAutoScrollingProvider);

        if (visibilityInfo.visibleFraction >= 0.6 && !isAutoScrolling) {
          final progressService = ref.read(progressServiceProvider);
          unawaited(
            progressService
                .setBookmarkImmediate(
                  mode: 'ayah',
                  surahId: selectedSurah.number,
                  ayah: widget.ayahNumber,
                )
                .then((_) {
                  if (mounted) {
                    ref.invalidate(lastReadProvider);
                    ref.invalidate(lastReadResolvedSurahProvider);
                    ref.invalidate(continueReadingProvider);
                  }
                }),
          );

          if (!_hasBeenTracked) {
            _visibilityTimer?.cancel();
            _visibilityTimer = Timer(_ayahDwellThreshold, () async {
              if (!mounted || _hasBeenTracked) return;
              _hasBeenTracked = true;

              await progressService.updateStreak();
              await progressService.trackAyah(
                selectedSurah.number,
                widget.ayahNumber,
              );

              if (!mounted) return;
              ref.invalidate(profileProgressProvider);
              ref.invalidate(continueReadingProvider);
              setState(() {});
            });
          }
        } else if (visibilityInfo.visibleFraction < 0.6) {
          _visibilityTimer?.cancel();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        color: isDark ? AppTheme.darkSurface : Colors.white,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? const BorderSide(color: AppTheme.darkBorder)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              // ================= TOP ROW =================
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrentlyPlaying
                          ? AppColors.emerald600
                          : (isDark
                                ? AppTheme.darkBorder
                                : AppColors.emerald600),
                    ),
                    child: Center(
                      child: Text(
                        "${widget.ayahNumber}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSpacing.size12,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Bookmark Icon
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
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
                                "${selectedSurah.nameEnglish} Verse ${widget.ayahNumber}",
                            initialNote: existing?.note,
                            isPageMode: false,
                          );

                          if (note == null || !mounted) return;
                          await ref
                              .read(bookmarkServiceProvider)
                              .addOrUpdateVerseBookmark(
                                surahId: selectedSurah.number,
                                ayahNumber: widget.ayahNumber,
                                note: note,
                              );
                          if (!mounted) return;
                          ref.invalidate(bookmarksProvider);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            isBookmarked
                                ? LucideIcons.bookmarkCheck
                                : LucideIcons.bookmark,
                            color: isBookmarked
                                ? AppColors.emerald600
                                : AppColors.gray400,
                            size: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 2. Share Icon
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final translationText = quran.getVerseTranslation(
                            widget.surahNumber,
                            widget.ayahNumber,
                          );
                          final shareText =
                              '"$ayahText"\n\n'
                              '"$translationText"\n\n'
                              '— Surah ${selectedSurah.nameEnglish} (${selectedSurah.number}:${widget.ayahNumber})\n'
                              'Shared via Bayyinah Flow';

                          await SharePlus.instance.share(
                            ShareParams(
                              text: shareText,
                              subject:
                                  "Surah ${selectedSurah.nameEnglish} (${selectedSurah.number}:${widget.ayahNumber})",
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            LucideIcons.share2,
                            color: AppColors.gray400,
                            size: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 3. Audio Icon
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final audio = ref.read(audioServiceProvider);
                          final reciter =
                              ref.read(defaultReciterProvider) ??
                              ref.read(selectedReciterProvider) ??
                              ref.read(recitersListProvider).first;

                          try {
                            await audio.playVerse(
                              reciter: reciter,
                              surah: selectedSurah,
                              ayah: widget.ayahNumber,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error playing verse: $e"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            LucideIcons.volume2,
                            color: isCurrentlyPlaying
                                ? AppColors.emerald600
                                : AppColors.gray400,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ================= ARABIC & TRANSLATION =================
              if (showAyahBefore) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: buildArabicTextWidget(),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: translationWidget,
                ),
              ] else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: translationWidget,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: buildArabicTextWidget(),
                ),
              ],
              const SizedBox(height: 8),
              Divider(
                color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                thickness: 1,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SelectedButton(
                      icon: LucideIcons.bookmarkCheck,
                      text: "Tafseer",
                      onTap: () {
                        showTafseerBottomSheet(
                          context,
                          surahName: selectedSurah.nameEnglish,
                          surahNumber: selectedSurah.number,
                          ayahNumber: widget.ayahNumber,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectedButton(
                      icon: LucideIcons.messageSquare,
                      text: "Reflection",
                      onTap: _handleReflectionTap,
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
