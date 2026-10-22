import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  test('Verify quran package getPageData', () {
    // Check page 602 (contains multiple surahs: 106, 107, 108)
    final pageData = quran.getPageData(602);
    print("Page 602 data type: ${pageData.runtimeType}");
    print("Page 602 data: $pageData");

    for (final entry in pageData) {
      print(
        "  entry keys: ${entry.keys}, surah: ${entry['surah']}, start: ${entry['start']}, end: ${entry['end']}",
      );
    }

    // Check page 1 (Surah 1)
    final page1Data = quran.getPageData(1);
    print("Page 1 data: $page1Data");

    // Check page 2 (Surah 2 starts)
    final page2Data = quran.getPageData(2);
    print("Page 2 data: $page2Data");
  });
}
