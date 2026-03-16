import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quran_app/features/quran/data/datasource/ayah_local_datasource.dart';
import 'app/app.dart';
import 'features/quran/data/repository/quran_repository.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.quran_app.channel.audio',
    androidNotificationChannelName: 'Quran Audio',
    androidNotificationOngoing: true,
  );

  runApp(
    const ProviderScope(
      child: QuranApp(),
    ),
  );
}
