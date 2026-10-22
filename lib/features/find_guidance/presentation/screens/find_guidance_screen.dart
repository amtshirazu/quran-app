import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: selectedEmotion == null
            ? const GuidanceHeader()
            : GuidanceVerseHeader(emotion: selectedEmotion)
                  as PreferredSizeWidget,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.03),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: selectedEmotion == null
                ? const SingleChildScrollView(
                    key: ValueKey('feelings_list'),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        GuidanceSubtitle(),
                        GuidanceFeelingsList(),
                        GuidanceFeelingsMatterBanner(),
                        SizedBox(height: 24),
                      ],
                    ),
                  )
                : GuidanceVersesList(
                    key: ValueKey('verses_$selectedEmotion'),
                    emotion: selectedEmotion,
                  ),
          ),
        ),
      ),
    );
  }
}
