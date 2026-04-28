import '../../domain/models/translation.dart';
import '../datasource/translation_local_datasource.dart';

class TranslationRepository {
  final TranslationLocalDatasource datasource;

  TranslationRepository({required this.datasource});

  Future<List<Translation>> getSurahTranslations({
    required int surahNumber,
    required String translationFile,
  }) async {
    final data = await datasource.loadTranslationJson(
      "assets/quran/translations/$translationFile.json",
    );

    final filtered = data
        .where((element) => element["surah_number"] == surahNumber)
        .toList();

    return filtered.map((e) => Translation.fromJson(e)).toList();
  }
}
