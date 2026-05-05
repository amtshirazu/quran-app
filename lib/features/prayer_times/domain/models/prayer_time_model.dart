class PrayerTimesModel {
  final String date;
  final double lat;
  final double lng;

  final Map<String, String> times;

  PrayerTimesModel({
    required this.date,
    required this.lat,
    required this.lng,
    required this.times,
  });
}
