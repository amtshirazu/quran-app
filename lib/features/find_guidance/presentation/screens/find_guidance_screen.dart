import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import '../state/guidance_provider.dart';
import '../widgets/guidance_header.dart';
import '../widgets/guidance_subtitle.dart';
import '../widgets/guidance_feelings_list.dart';
import '../widgets/guidance_feelings_matter_banner.dart';
import '../widgets/guidance_verse_header.dart';
import '../widgets/guidance_verses_list.dart';

class FindGuidanceScreen extends ConsumerWidget {
  const FindGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEmotion = ref.watch(selectedEmotionProvider);

    return PopScope(
      canPop: selectedEmotion == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectedEmotion != null) {
          ref.read(selectedEmotionProvider.notifier).state = null;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: selectedEmotion == null
            ? const GuidanceHeader()
            : GuidanceVerseHeader(emotion: selectedEmotion) as PreferredSizeWidget,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.emerald50, // Light emerald top tint
                Colors.white,        // Fades to white
              ],
              stops: [0.0, 0.4],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: selectedEmotion == null
                ? const Column(
                    children: [
                      GuidanceSubtitle(),
                      GuidanceFeelingsList(),
                      GuidanceFeelingsMatterBanner(),
                      SizedBox(height: 24),
                    ],
                  )
                : Column(
                    children: [
                      GuidanceVersesList(emotion: selectedEmotion),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
