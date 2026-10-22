import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Continue Reading Page 13 of Surah 2 validates against Surah 2 page range',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final surah2 = Surah(
        number: 2,
        nameArabic: "البقرة",
        nameEnglish: "Al-Baqarah",
        translation: "The Cow",
        totalAyahs: 286,
        revelationType: "Medinan",
      );

      // Simulate Continue Reading tap on Page 13 of Surah 2
      container.read(selectedSurahProvider.notifier).state = surah2;
      container.read(explicitSurahSelectionProvider.notifier).state = surah2;
      container.read(shouldResumeLastReadProvider.notifier).state = true;
      container.read(jumpToPageProvider.notifier).state = 13;

      final range = surahPageRanges[surah2.number];
      expect(range, isNotNull);
      expect(range!.start, equals(2));
      expect(range.end, equals(49));

      final jumpPage = container.read(jumpToPageProvider);
      expect(jumpPage, equals(13));

      int initialPage = range.start;
      if (jumpPage != null &&
          jumpPage >= range.start &&
          jumpPage <= range.end) {
        initialPage = jumpPage;
      }

      expect(
        initialPage,
        equals(13),
        reason:
            'Page 13 falls within Surah 2 range [2, 49] so initialPage must be 13',
      );
    },
  );
}
