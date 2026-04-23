import 'package:quran_app/features/quran/data/datasource/ayah_local_datasource.dart';
import '../../domain/models/ayah.dart';

class QuranRepository {
  final QuranLocalDatasource datasource;

  QuranRepository({required this.datasource});

  Future<List<Ayah>> getSurahAyahs({
    required int surahNumber,
    required String script,
  }) async {
    final data = await datasource.loadQuranJson(
      "assets/quran/scripts/$script.json",
    );
    final filtered = data
        .where((element) => element["surah_number"] == surahNumber)
        .toList();
    return filtered.map((e) => Ayah.fromJson(e)).toList();
  }
}
