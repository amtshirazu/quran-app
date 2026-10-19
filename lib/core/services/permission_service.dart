import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionCoordinator {
  static bool _isRequesting = false;

  static Future<void> requestInitialPermissions() async {
    if (_isRequesting) return;
    _isRequesting = true;

    try {
      // Step 1: Request Notification Permission first (Android 13+)
      final notifStatus = await Permission.notification.status;
      debugPrint('🔔 NOTIFICATION STATUS BEFORE: $notifStatus');

      if (!notifStatus.isGranted) {
        final result = await Permission.notification.request();
        debugPrint('🔔 NOTIFICATION REQUEST RESULT: $result');
      }

      // Small delay to let the Android Activity window completely dismiss the first notification dialog
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Request Location Permission strictly AFTER the notification dialog finishes
      LocationPermission locStatus = await Geolocator.checkPermission();
      debugPrint('📍 LOCATION STATUS BEFORE: $locStatus');

      if (locStatus == LocationPermission.denied) {
        locStatus = await Geolocator.requestPermission();
        debugPrint('📍 LOCATION REQUEST RESULT: $locStatus');
      }
    } catch (e) {
      debugPrint('❌ Permission coordination error: $e');
    } finally {
      _isRequesting = false;
    }
  }
}
