import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/core/notifications/notification_service.dart';

class DailyVerseNotificationNotifier extends StateNotifier<bool> {
  DailyVerseNotificationNotifier() : super(true) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting(
        'daily_verse_notif_enabled',
      );
      if (saved != null) {
        state = saved == 'true';
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await DatabaseHelper.instance.setSetting(
      'daily_verse_notif_enabled',
      enabled ? 'true' : 'false',
    );
    if (!enabled) {
      await NotificationService.instance.cancelDailyVerseNotification();
    }
  }
}

final dailyVerseNotifEnabledProvider =
    StateNotifierProvider<DailyVerseNotificationNotifier, bool>((ref) {
      return DailyVerseNotificationNotifier();
    });

class DailyVerseTimeNotifier extends StateNotifier<TimeOfDay> {
  DailyVerseTimeNotifier() : super(const TimeOfDay(hour: 8, minute: 0)) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await DatabaseHelper.instance.getSetting(
        'daily_verse_notif_time',
      );
      if (saved != null) {
        final parts = saved.split(':');
        if (parts.length == 2) {
          final h = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          if (h != null && m != null) {
            state = TimeOfDay(hour: h, minute: m);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> setTime(TimeOfDay time) async {
    state = time;
    await DatabaseHelper.instance.setSetting(
      'daily_verse_notif_time',
      '${time.hour}:${time.minute}',
    );
  }
}

final dailyVerseNotifTimeProvider =
    StateNotifierProvider<DailyVerseTimeNotifier, TimeOfDay>((ref) {
      return DailyVerseTimeNotifier();
    });
