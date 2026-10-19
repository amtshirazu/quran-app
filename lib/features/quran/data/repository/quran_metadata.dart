import 'package:quran_app/features/quran/data/datasource/surah_local_datasource.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';

class SurahMetadataRepository {
  final SurahLocalDatasource surahs;

  SurahMetadataRepository({required this.surahs});

  Future<List<Surah>> getSurahMetadata() async {
    return await surahs.loadSurahs();
  }
}
