import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/core/notifications/notification_service.dart';
import 'package:quran_app/features/prayer_times/domain/models/next_prayer_time_model.dart';
import 'package:quran_app/features/prayer_times/presentation/states/prayer_times_service.dart';
import 'package:geocoding/geocoding.dart';

final prayerTimesServiceProvider = Provider((ref) => PrayerTimesService());

class EnabledPrayersNotifier extends StateNotifier<List<String>> {
  EnabledPrayersNotifier() : super(['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting('enabled_prayers_list');
      if (saved != null && saved.isNotEmpty) {
        final list = saved.split(',').where((s) => s.trim().isNotEmpty).toList();
        if (list.isNotEmpty) {
          state = list;
        }
      }
    } catch (_) {}
  }

  Future<void> togglePrayer(String prayerName, bool enabled) async {
    final copy = List<String>.from(state);
    if (enabled && !copy.contains(prayerName)) {
      copy.add(prayerName);
    } else if (!enabled && copy.contains(prayerName)) {
      copy.remove(prayerName);
    }
    state = copy;
    await DatabaseHelper.instance.setSetting('enabled_prayers_list', copy.join(','));
  }
}

final enabledPrayersProvider =
    StateNotifierProvider<EnabledPrayersNotifier, List<String>>((ref) {
  return EnabledPrayersNotifier();
});

String _firstNonEmpty(List<String?> candidates, String fallback) {
  for (final candidate in candidates) {
    if (candidate != null && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }
  return fallback;
}

// Fetches GPS location with diagnostic logging and fallback
final locationProvider = FutureProvider<Position>((ref) async {
  debugPrint("📍 LOCATION: Starting location detection...");

  final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  debugPrint("📍 LOCATION: Service enabled = $serviceEnabled");
  if (!serviceEnabled) {
    throw 'Location services are disabled on device.';
  }

  LocationPermission permission = await Geolocator.checkPermission();
  debugPrint("📍 LOCATION: Current permission = $permission");

  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied. Please enable them in app settings.';
  }

  if (permission == LocationPermission.denied) {
    debugPrint("📍 LOCATION: Requesting location permission...");
    permission = await Geolocator.requestPermission();
    debugPrint("📍 LOCATION: Permission after request = $permission");

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied. Please enable them in app settings.';
    }
    if (permission == LocationPermission.denied) {
      throw 'Location permissions were denied.';
    }
  }

  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100,
    timeLimit: Duration(seconds: 60),
  );

  try {
    debugPrint("📍 LOCATION: Requesting current position...");
    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    debugPrint("✅ LOCATION: Position received");
    debugPrint("   Latitude: ${position.latitude}");
    debugPrint("   Longitude: ${position.longitude}");
    debugPrint("   Accuracy: ${position.accuracy}");
    return position;
  } catch (e) {
    debugPrint("⚠️ LOCATION: getCurrentPosition failed: $e");
    debugPrint("📍 LOCATION: Attempting to fetch last known position...");
    final lastKnown = await Geolocator.getLastKnownPosition();

    if (lastKnown != null) {
      debugPrint("✅ LOCATION: Last known position fetched successfully");
      debugPrint("   Latitude: ${lastKnown.latitude}");
      debugPrint("   Longitude: ${lastKnown.longitude}");
      return lastKnown;
    }

    debugPrint("❌ LOCATION: No last known position available.");
    throw 'Failed to acquire current or last known GPS location: $e';
  }
});

final countryAndCityNameProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final position = await ref.watch(locationProvider.future);

  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      for (final place in placemarks) {
        final city = _firstNonEmpty([
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.subLocality,
          place.name,
        ], "");

        final country = _firstNonEmpty([
          place.country,
        ], "Unknown Country");

        if (city.isNotEmpty) {
          return {
            "city": city,
            "country": country,
          };
        }
      }

      final firstPlace = placemarks.first;
      final fallbackCity = _firstNonEmpty([
        firstPlace.administrativeArea,
        firstPlace.subAdministrativeArea,
        firstPlace.name,
      ], "Unknown City");

      return {
        "city": fallbackCity,
        "country": _firstNonEmpty([firstPlace.country], "Unknown Country"),
      };
    }
    return {"city": "Unknown Location", "country": "Unknown Country"};
  } catch (e) {
    debugPrint("Geocoding Error: $e");
    return {"city": "Unknown Location", "country": "Unknown Country"};
  }
});

final prayerTimesProvider = FutureProvider<Map<String, DateTime>>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final countryAndCityName =
      await ref.watch(countryAndCityNameProvider.future).catchError(
            (_) => {"city": "Unknown Location", "country": "Unknown Country"},
          );
  final service = ref.read(prayerTimesServiceProvider);
  final enabledPrayers = ref.watch(enabledPrayersProvider);

  debugPrint("📍 LOCATION FETCHED:");
  debugPrint("   Latitude: ${position.latitude}");
  debugPrint("   Longitude: ${position.longitude}");
  debugPrint("   City: ${countryAndCityName['city']}");
  debugPrint("   Country: ${countryAndCityName['country']}");

  final times = service.calculateTodayTimes(
    lat: position.latitude,
    lng: position.longitude,
  );

  debugPrint("🕌 CALCULATED PRAYER TIMES:");
  times.forEach((name, time) {
    debugPrint("   $name: ${DateFormat.jm().format(time)} (Full: $time)");
  });

  // Automatically schedule rolling 7 days of Adhan notifications
  unawaited(
    NotificationService.instance.schedule7DayPrayerNotifications(
      todayTimes: times,
      enabledPrayers: enabledPrayers,
    ),
  );

  return times;
});

final nextPrayerProvider = Provider<MapEntry<String, DateTime>?>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  final locationAsync = ref.watch(locationProvider);

  return timesAsync.maybeWhen(
    data: (times) {
      final now = DateTime.now();
      try {
        final obligatoryPrayers = times.entries.where((e) => e.key != "Sunrise");
        return obligatoryPrayers.firstWhere((e) => e.value.isAfter(now));
      } catch (_) {
        final location = locationAsync.asData?.value;
        if (location != null) {
          final service = ref.read(prayerTimesServiceProvider);
          final tomorrowTimes = service.calculateTomorrowTimes(
            lat: location.latitude,
            lng: location.longitude,
          );
          final tomorrowFajr = tomorrowTimes["Fajr"];
          if (tomorrowFajr != null) {
            return MapEntry("Fajr", tomorrowFajr);
          }
        }
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

  final difference = prayerTime.difference(now);
  String remaining;
  if (difference.isNegative) {
    remaining = "Passed";
  } else {
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    remaining = hours > 0 ? "in ${hours}h ${minutes}m" : "in ${minutes}m";
  }

  return NextPrayerUIModel(
    prayerName: nextPrayer.key,
    formattedTime: DateFormat.jm().format(prayerTime),
    remainingTime: remaining,
  );
});
