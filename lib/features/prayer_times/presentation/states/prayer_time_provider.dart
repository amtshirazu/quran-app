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

Future<Position>? _activeLocationFuture;

Future<Position> _fetchLocationInverted() async {
  debugPrint("📍 LOCATION: Starting inverted location retrieval...");

  final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled on device.';
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;
    throw 'Location permission not granted. Please enable location permissions.';
  }

  // Strategy Step 1: Immediately fetch last known position for 0-delay display
  final lastKnown = await Geolocator.getLastKnownPosition();
  if (lastKnown != null) {
    debugPrint("⚡ LOCATION: Instant last known position retrieved (${lastKnown.latitude}, ${lastKnown.longitude})");
  }

  // Strategy Step 2: Fetch current position with strict 7-second timeout
  try {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.low,
      distanceFilter: 100,
      timeLimit: Duration(seconds: 60),
    );
    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    debugPrint("✅ LOCATION: Fresh position received (${currentPosition.latitude}, ${currentPosition.longitude})");
    return currentPosition;
  } catch (e) {
    debugPrint("⚠️ LOCATION: Fresh position timed out (60s). Using last known position: $e");
    if (lastKnown != null) return lastKnown;
    rethrow;
  }
}

// Inverted Fast Location Retrieval Strategy (Re-entrancy Guarded)
final locationProvider = FutureProvider<Position>((ref) async {
  if (_activeLocationFuture != null) {
    debugPrint("⚡ LOCATION: Reusing active location retrieval in progress...");
    return await _activeLocationFuture!;
  }

  _activeLocationFuture = _fetchLocationInverted();
  try {
    final position = await _activeLocationFuture!;
    return position;
  } finally {
    _activeLocationFuture = null;
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

String? _lastScheduledNotificationSignature;

final prayerTimesProvider = FutureProvider<Map<String, DateTime>>((ref) async {
  final position = await ref.watch(locationProvider.future);
  final service = ref.read(prayerTimesServiceProvider);
  final enabledPrayers = ref.watch(enabledPrayersProvider);

  final times = service.calculateTodayTimes(
    lat: position.latitude,
    lng: position.longitude,
  );

  // Execution Guard: Deduping notification scheduling sessions
  final signature = "${position.latitude.toStringAsFixed(3)}_${position.longitude.toStringAsFixed(3)}_${enabledPrayers.join('-')}";
  if (_lastScheduledNotificationSignature != signature) {
    _lastScheduledNotificationSignature = signature;
    debugPrint("🕌 NOTIFICATIONS: Scheduling fresh 7-day batch for signature [$signature]");
    unawaited(
      NotificationService.instance.schedule7DayPrayerNotifications(
        todayTimes: times,
        enabledPrayers: enabledPrayers,
      ),
    );
  }

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
