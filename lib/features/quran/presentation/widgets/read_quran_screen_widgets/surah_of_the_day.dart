import 'dart:math';
import '../../../domain/models/surah.dart';





Surah? getSurahOfTheDay(List<Surah> surahlist) {

     final today = DateTime.now();

     final seed = today.year*10000 + today.month*100 + today.day;
     final random = Random(seed);

     final index = random.nextInt(surahlist.length);
     return surahlist[index];
}