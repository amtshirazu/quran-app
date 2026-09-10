class TafseerModel {
  final String dbFileName;
  final String name;
  final String language;
  final String languageCode;
  final String description;
  final bool isDefault;

  const TafseerModel({
    required this.dbFileName,
    required this.name,
    required this.language,
    required this.languageCode,
    required this.description,
    this.isDefault = false,
  });
}

const List<TafseerModel> kAllTafseers = [
  TafseerModel(
    dbFileName: 'en_tafisr-ibn-kathir.db',
    name: 'Tafsir Ibn Kathir',
    language: 'English',
    languageCode: 'en',
    description: 'Renowned classical commentary by Hafiz Ibn Kathir',
    isDefault: true,
  ),
  TafseerModel(
    dbFileName: 'en_al-mukhtasar.db',
    name: 'Al-Mukhtasar in Tafsir',
    language: 'English',
    languageCode: 'en',
    description: 'Concise and simplified explanation of Quranic meanings',
  ),
  TafseerModel(
    dbFileName: 'en_tafsir-al-jalalayn.db',
    name: 'Tafsir Al-Jalalayn',
    language: 'English',
    languageCode: 'en',
    description: 'Classic commentary by Jalal ad-Din al-Mahalli & al-Suyuti',
  ),
  TafseerModel(
    dbFileName: 'ar-tafseer-al-saddi.db',
    name: 'تفسير السعدي (Al-Saddi)',
    language: 'Arabic',
    languageCode: 'ar',
    description: 'Tafsir As-Sa\'di by Shaykh Abd ar-Rahman al-Sa\'di',
  ),
  TafseerModel(
    dbFileName: 'tr-tafsir-ibne-kathir.db',
    name: 'Tefsiri İbn Kesir',
    language: 'Turkish',
    languageCode: 'tr',
    description: 'İbn Kesir Kur\'an-ı Kerim Tefsiri',
  ),
];
