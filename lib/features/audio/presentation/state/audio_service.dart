import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';

import '../../../quran/domain/models/surah.dart';
import '../../../quran/presentation/state/quran_providers.dart';
import 'audio_providers.dart';


class AudioService {

     final AudioPlayer _audioPlayer = AudioPlayer();

     bool _hasBasmallah = false;

     void init(WidgetRef ref) {
       _audioPlayer.currentIndexStream.listen((index) {

         if (index == null) return;
         final current = ref.read(currentPlayingAyahProvider);
         int ayahNumber = index + 1;

         if (_hasBasmallah) {
           ayahNumber = index;
           if (ayahNumber == 0) return;
         }

         if (current != null) {
           ref.read(currentPlayingAyahProvider.notifier).state = AyahIdentifier(
               surah: current.surah,
               ayah: ayahNumber,
               page: current.page
           );
         }
       });


       _audioPlayer.processingStateStream.listen((state) async {
         if (state == ProcessingState.completed) {
           final repeatMode = ref.read(repeatModeProvider);
           final currentReciter = ref.read(selectedReciterProvider);
           final currentIndex = ref.read(selectedSurahIndexProvider)!;
           final surahsAsync = ref.read(surahListProvider);

           if (surahsAsync is AsyncData<List<Surah>>) {
             final surahs = surahsAsync.value;

             if (repeatMode == RepeatStates.repeatAll) {
               final nextIndex = (currentIndex + 1) % surahs.length;
               ref.read(selectedSurahIndexProvider.notifier).state = nextIndex;

               final nextSurah = surahs[nextIndex];
               await playSurah(
                 reciterFolder: currentReciter!.audioFolder,
                 surah: nextSurah.number,
                 totalAyahs: nextSurah.totalAyahs,
               );
             } else if (repeatMode == RepeatStates.repeatOne) {
               final surah = surahs[currentIndex];
               await playSurah(
                 reciterFolder: currentReciter!.audioFolder,
                 surah: surah.number,
                 totalAyahs: surah.totalAyahs,
               );
             } else {
               await _audioPlayer.stop();
             }
           }
         }
       });
     }

     bool _hasLoadedSurah = false;

     bool get hasLoadedSurah => _hasLoadedSurah;

     AudioPlayer get player => _audioPlayer;

     Future<void> playVerse({
       required String reciterFolder,
       required int surah,
       required int ayah,
     }) async {
       final url = buildUrl(
           surah : surah,
           ayah : ayah,
           reciterFolder : reciterFolder
       );
       await playUrl(url);
     }

     Future<void> playUrl(String url) async {
         await _audioPlayer.setUrl(url);
         await _audioPlayer.play();
     }

     Future<void> play() async {
       await _audioPlayer.play();
     }

     Future<void> pause() async {
       await _audioPlayer.pause();
     }

     Future<void> stop() async {
       await _audioPlayer.stop();
     }

     void dispose() {
       _audioPlayer.dispose();
     }

     String buildUrl({
       required int surah,
       required int ayah,
       required String reciterFolder,
     }){
       final surahStr = surah.toString().padLeft(3, '0');
       final ayahStr = ayah.toString().padLeft(3, '0');

       return "https://everyayah.com/data/$reciterFolder/$surahStr$ayahStr.mp3";
     }


     Future<void> playSurah({
       required String reciterFolder,
       required int surah,
       required int totalAyahs,
     }) async {

       await _audioPlayer.stop();
       final surahStr = surah.toString().padLeft(3, '0');
       List<AudioSource> ayahs = [];
       _hasBasmallah = false;

       if (surah != 1 && surah != 9 && reciterFolder != "warsh/warsh_yassin_al_jazaery_64kbps") {
         final basmallahUrl =
             "https://everyayah.com/data/$reciterFolder/001001.mp3";

         ayahs.add(AudioSource.uri(Uri.parse(basmallahUrl)));
         _hasBasmallah = true;
       }

       ayahs.addAll(
         List.generate(totalAyahs, (i) {
           final ayahStr = (i + 1).toString().padLeft(3, '0');

           final url =
               "https://everyayah.com/data/$reciterFolder/$surahStr$ayahStr.mp3";

           return AudioSource.uri(Uri.parse(url));
         }),
       );

       await _audioPlayer.setAudioSources(ayahs);
       _hasLoadedSurah = true;
       await _audioPlayer.play();
     }

     Future<void> seekToStart() async {
       await _audioPlayer.seek(Duration.zero);
     }

     Future<void> reset() async {
       await _audioPlayer.stop();
       await _audioPlayer.seek(Duration.zero);
       await _audioPlayer.setAudioSources([]);

       _hasLoadedSurah = false;
     }

     Future<void> setVolume(double volume) async {
       await _audioPlayer.setVolume(volume);
     }

}