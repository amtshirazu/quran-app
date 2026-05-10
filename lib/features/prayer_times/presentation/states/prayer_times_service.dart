import 'package:adhan/adhan.dart';

class PrayerTimesService {
  Map<String, DateTime> calculateTodayTimes({
    required double lat,
    required double lng,
    String? countryCode,
  }) {
    final coordinates = Coordinates(lat, lng);

    CalculationParameters params = CalculationMethod.muslim_world_league
        .getParameters();

    if (lat > 36.0 && lat < 42.0 && lng > 26.0 && lng < 45.0) {
      params = CalculationMethod.turkey.getParameters();
    }

    params.madhab = Madhab.shafi; // Standard global default

    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);

    return {
      "Fajr": prayerTimes.fajr.toLocal(),
      "Sunrise": prayerTimes.sunrise.toLocal(),
      "Dhuhr": prayerTimes.dhuhr.toLocal(),
      "Asr": prayerTimes.asr.toLocal(),
      "Maghrib": prayerTimes.maghrib.toLocal(),
      "Isha": prayerTimes.isha.toLocal(),
    };
  }
}
