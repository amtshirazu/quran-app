import 'package:audio_service/audio_service.dart';
import 'audio_service.dart';

class QuranAudioHandler extends BaseAudioHandler with QueueHandler {

  final QuranAudioService audioService;

  QuranAudioHandler(this.audioService);

  @override
  Future<void> play() => audioService.play();

  @override
  Future<void> pause() => audioService.pause();

  @override
  Future<void> stop() => audioService.stop();

  @override
  Future<void> skipToNext() async {
    audioService.player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    audioService.player.seekToPrevious();
  }
}