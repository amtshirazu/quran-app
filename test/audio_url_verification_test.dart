@Timeout(Duration(minutes: 2))
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/features/audio/data/reciters_list.dart';

void main() {
  test('Verify reciter audio URLs on CDN for Surah 1, 55, and 114', () async {
    final testSurahs = [1, 55, 114];

    for (final reciter in reciters) {
      final cleanBaseUrl = reciter.serverUrl.endsWith('/')
          ? reciter.serverUrl.substring(0, reciter.serverUrl.length - 1)
          : reciter.serverUrl;

      for (final surahNum in testSurahs) {
        final fileName = '${surahNum.toString().padLeft(3, '0')}.mp3';
        final url = Uri.parse('$cleanBaseUrl/$fileName');

        final res = await http.head(url);
        expect(
          res.statusCode,
          equals(200),
          reason: 'Audio URL $url must return HTTP 200',
        );
      }
    }
  });
}
