import 'package:quran_app/features/quran/domain/models/surah.dart';

class ReflectionUIModel {
  final int id;
  final Surah surah;
  final int ayahNumber;
  final String content;
  final DateTime date;

  ReflectionUIModel({
    required this.id,
    required this.surah,
    required this.ayahNumber,
    required this.content,
    required this.date,
  });
}
