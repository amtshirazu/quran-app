import 'package:just_audio/just_audio.dart';


class AudioService {

     final AudioPlayer _audioPlayer = AudioPlayer();
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

       List<AudioSource> ayahs = List.generate(totalAyahs, (i) {
          final ayahNum = (i + 1).toString().padLeft(3, '0');
          final surahStr = surah.toString().padLeft(3, '0');

          final url = "https://everyayah.com/data/$reciterFolder/$surahStr$ayahNum.mp3";

          return AudioSource.uri(Uri.parse(url));
       });

       await _audioPlayer.setAudioSources(ayahs);
       await _audioPlayer.play();
     }


}