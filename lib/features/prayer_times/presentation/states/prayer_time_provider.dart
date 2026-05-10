import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/features/prayer_times/domain/models/next_prayer_time_model.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_times_service.dart';
import 'package:geocoding/geocoding.dart';

final prayerTimesServiceProvider = Provider((ref) => PrayerTimesService());

final countryAndCityNameProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final position = await ref.watch(locationProvider.future);

  try {
    // Reverse geocode the coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;

      return {
        "city":
            place.administrativeArea ?? place.locality ?? "Unknown Location",
        "country": place.country ?? "Unknown Country",
      };
    }
    return {"city": "Unknown Location", "country": "Unknown Country"};
  } catch (e) {
    debugPrint("Geocoding Error: $e");
    return {"city": "Location Error", "country": "Location Error"};
  }
});

// Fetches GPS every time it's watched/invalidated
final locationProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw 'Location services are disabled.';

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) throw 'Permissions denied.';
  }

  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100,
    timeLimit: Duration(seconds: 120),
  );

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  } catch (e) {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;
    rethrow;
  }
});

final prayerTimesProvider = FutureProvider<Map<String, DateTime>>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final countryAndCityName = await ref.watch(countryAndCityNameProvider.future);
  final service = ref.read(prayerTimesServiceProvider);

  // Debugging logs for CLI
  debugPrint("📍 LOCATION FETCHED:");
  debugPrint("   Latitude: ${position.latitude}");
  debugPrint("   Longitude: ${position.longitude}");
  debugPrint("   City: ${countryAndCityName['city']}");
  debugPrint("   Country: ${countryAndCityName['country']}");
  debugPrint("   Device Time: ${DateTime.now()}");
  debugPrint("   Timezone Offset: ${DateTime.now().timeZoneOffset}");

  final times = service.calculateTodayTimes(
    lat: position.latitude,
    lng: position.longitude,
  );

  debugPrint("🕌 CALCULATED PRAYER TIMES:");
  times.forEach((name, time) {
    debugPrint("   $name: ${DateFormat.jm().format(time)} (Full: $time)");
  });

  return times;
});

final nextPrayerProvider = Provider<MapEntry<String, DateTime>?>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);

  return timesAsync.maybeWhen(
    data: (times) {
      final now = DateTime.now();
      try {
        return times.entries.firstWhere((e) => e.value.isAfter(now));
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});

final nextPrayerUIProvider = Provider<NextPrayerUIModel?>((ref) {
  final nextPrayer = ref.watch(nextPrayerProvider);

  if (nextPrayer == null) return null;

  final now = DateTime.now();
  final prayerTime = nextPrayer.value;

  // 1. Calculate Remaining Time String
  final difference = prayerTime.difference(now);
  String remaining;
  if (difference.isNegative) {
    remaining = "Passed";
  } else {
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    remaining = hours > 0 ? "in ${hours}h ${minutes}m" : "in ${minutes}m";
  }

  // 2. Return the UI Model with pre-formatted values
  return NextPrayerUIModel(
    prayerName: nextPrayer.key,
    formattedTime: DateFormat.jm().format(prayerTime),
    remainingTime: remaining,
  );
});
