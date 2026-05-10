import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:quran_app/shimeers/mushaf_page_shimmer.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.quran_app.channel.audio',

    androidNotificationChannelName: 'Quran Audio',

    androidNotificationOngoing: true,
  );

  await QcfFontLoader.setupFontsAtStartup(
    onProgress: (progress) {
      return MushafPageShimmer();
    },
  );

  runApp(const ProviderScope(child: QuranApp()));
}
