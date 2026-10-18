import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/quran/presentation/state/daily_verse_provider.dart';
import 'package:quran_app/features/settings/presentation/state/notification_settings_provider.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initFuture;

  static const String prayerChannelId = 'prayer_times_channel';
  static const String prayerChannelName = 'Prayer Times & Adhan';
  static const int dailyVerseNotificationId = 8888;

  Future<void> init() async {
    if (_initialized) return;
    if (_initFuture != null) {
      return _initFuture!;
    }

    _initFuture = _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("📍 NOTIFICATIONS: Local timezone set to $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ NOTIFICATIONS: Could not detect local timezone: $e");
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notification tapped with payload: ${details.payload}");
      },
    );

    if (Platform.isAndroid) {
      final prayerChannel = AndroidNotificationChannel(
        prayerChannelId,
        prayerChannelName,
        description: 'Adhan reminders for prayer times',
        importance: Importance.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('adhan'),
      );

      const verseChannel = AndroidNotificationChannel(
        'daily_verse_channel',
        'Daily Verse Reminders',
        description: 'Daily Verse of the Day notifications',
        importance: Importance.high,
        playSound: true,
      );

      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(prayerChannel);
        await androidImplementation.createNotificationChannel(verseChannel);
        try {
          await androidImplementation.requestNotificationsPermission();
        } catch (e) {
          debugPrint("⚠️ NOTIFICATIONS: requestNotificationsPermission skipped: $e");
        }
        try {
          await androidImplementation.requestExactAlarmsPermission();
        } catch (e) {
          debugPrint("⚠️ NOTIFICATIONS: requestExactAlarmsPermission skipped: $e");
        }
      }
    }

    _initialized = true;
  }

  /// Automatically checks settings and schedules Daily Verse & Prayer Alarms on app launch
  Future<void> autoScheduleOnLaunch(WidgetRef ref) async {
    await init();
    try {
      final isEnabled = ref.read(dailyVerseNotifEnabledProvider);
      if (isEnabled) {
        final time = ref.read(dailyVerseNotifTimeProvider);
        final verseData = ref.read(dailyVerseWithTranslationProvider).asData?.value;
        final text = verseData?.translation ?? "Verily, with hardship comes ease.";
        await scheduleDailyVerseNotification(
          time: time,
          verseText: text,
        );
      }
    } catch (e) {
      debugPrint("⚠️ NOTIFICATIONS: Auto-schedule on launch error: $e");
    }
  }

  /// Checks whether system notification permission is currently granted
  Future<bool> areNotificationsEnabled() async {
    await init();
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  /// Checks permission status. If disabled in phone settings, displays an
  /// informative dialog with an [Open Settings] button.
  Future<bool> checkAndRequestPermission(BuildContext context) async {
    final isEnabled = await areNotificationsEnabled();
    if (isEnabled) return true;

    if (!context.mounted) return false;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          title: Text(
            "Notification Permission Required",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
            ),
          ),
          content: Text(
            "Notifications are currently turned off in your device settings. To receive Adhan and Daily Verse reminders, please enable notifications in Settings.",
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );

    if (openSettings == true) {
      await Geolocator.openAppSettings();
    }

    return false;
  }

  Future<void> _safeZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      debugPrint("✅ NOTIFICATION [$id] scheduled for $scheduledDate (exact)");
    } catch (e) {
      debugPrint("⚠️ NOTIFICATION [$id] exact schedule failed, falling back to inexact: $e");
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      debugPrint("✅ NOTIFICATION [$id] scheduled for $scheduledDate (inexact)");
    }
  }

  /// Schedule rolling 7 days of notifications for prayer times
  Future<void> schedule7DayPrayerNotifications({
    required Map<String, DateTime> todayTimes,
    required List<String> enabledPrayers,
  }) async {
    await init();

    final List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      for (int prayerIndex = 0; prayerIndex < prayerNames.length; prayerIndex++) {
        final name = prayerNames[prayerIndex];
        final id = (dayIndex * 10) + prayerIndex;

        if (!enabledPrayers.contains(name)) {
          await _notificationsPlugin.cancel(id);
          continue;
        }

        final baseTime = todayTimes[name];
        if (baseTime == null) continue;

        final targetTime = baseTime.add(Duration(days: dayIndex));
        if (targetTime.isBefore(DateTime.now())) continue;

        final tzTime = tz.TZDateTime.from(targetTime, tz.local);

        await _safeZonedSchedule(
          id: id,
          title: 'Time for $name',
          body: 'It is time for $name prayer.',
          scheduledDate: tzTime,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              prayerChannelId,
              prayerChannelName,
              channelDescription: 'Adhan reminders for prayer times',
              importance: Importance.max,
              priority: Priority.high,
              category: AndroidNotificationCategory.alarm,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('adhan'),
            ),
            iOS: DarwinNotificationDetails(
              sound: 'adhan.mp3',
              presentAlert: true,
              presentSound: true,
            ),
          ),
        );
      }
    }
  }

  /// Cancel specific prayer across all 7 days
  Future<void> cancelPrayerNotification(String prayerName) async {
    final List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final prayerIndex = prayerNames.indexOf(prayerName);
    if (prayerIndex == -1) return;

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final id = (dayIndex * 10) + prayerIndex;
      await _notificationsPlugin.cancel(id);
    }
  }

  /// Schedule Daily Verse Notification
  Future<void> scheduleDailyVerseNotification({
    required TimeOfDay time,
    required String verseText,
  }) async {
    await init();
    await _notificationsPlugin.cancel(dailyVerseNotificationId);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _safeZonedSchedule(
      id: dailyVerseNotificationId,
      title: 'Verse of the Day 📖',
      body: verseText,
      scheduledDate: tzTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_verse_channel',
          'Daily Verse Reminders',
          channelDescription: 'Daily Verse of the Day notifications',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.reminder,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/verseOfDay',
    );
  }

  /// Cancel Daily Verse Notification
  Future<void> cancelDailyVerseNotification() async {
    await _notificationsPlugin.cancel(dailyVerseNotificationId);
  }
}
