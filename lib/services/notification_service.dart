import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prayer_times_service.dart';

/// Manages local notifications for prayer reminders and motivational nudges.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize the notification plugin. Call once at app startup.
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions (needed on iOS/macOS).
  static Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final darwin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await darwin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // ── Notification channel details ──
  static const _prayerChannel = AndroidNotificationDetails(
    'prayer_reminders',
    'Prayer Reminders',
    channelDescription: 'Notifications for upcoming prayer times',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
    icon: '@mipmap/ic_launcher',
  );

  static const _motivationChannel = AndroidNotificationDetails(
    'motivation',
    'Motivational Reminders',
    channelDescription: 'Daily motivational nudges and streak reminders',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    icon: '@mipmap/ic_launcher',
  );

  /// Schedule prayer reminder notifications for today based on actual prayer times.
  static Future<void> schedulePrayerReminders(
    TodayPrayerTimes prayerTimes,
  ) async {
    await cancelPrayerReminders();

    final now = DateTime.now();
    final prayers = [
      ('Fajr', prayerTimes.fajr, '🌅 Fajr prayer time has arrived.'),
      ('Dhuhr', prayerTimes.dhuhr, '☀️ Dhuhr prayer time has arrived.'),
      ('Asr', prayerTimes.asr, '🌤 Asr prayer time has arrived.'),
      (
        'Maghrib',
        prayerTimes.maghrib,
        '🌙 Maghrib prayer time — time to break your fast!',
      ),
      ('Isha', prayerTimes.isha, '✨ Isha prayer time has arrived.'),
    ];

    for (int i = 0; i < prayers.length; i++) {
      final (name, time, body) = prayers[i];
      if (time.isBefore(now)) continue;

      // Schedule AT prayer time
      _scheduleDelayedShow(
        id: 100 + i,
        title: 'Time for $name',
        body: body,
        scheduledTime: time,
        channel: _prayerChannel,
        payload: 'prayer_$name',
      );

      // Schedule 10-min BEFORE prayer
      final reminderTime = time.subtract(const Duration(minutes: 10));
      if (reminderTime.isAfter(now)) {
        _scheduleDelayedShow(
          id: 200 + i,
          title: '$name in 10 minutes',
          body: 'Prepare for $name prayer 🤲',
          scheduledTime: reminderTime,
          channel: _prayerChannel,
          payload: 'prayer_reminder_$name',
        );
      }
    }

    // Imsak / Suhoor reminder (30 min before Fajr)
    final suhoorReminder = prayerTimes.fajr.subtract(
      const Duration(minutes: 30),
    );
    if (suhoorReminder.isAfter(now)) {
      _scheduleDelayedShow(
        id: 300,
        title: 'Suhoor Window Closing',
        body: '30 minutes until Fajr. Complete your suhoor 🍽',
        scheduledTime: suhoorReminder,
        channel: _prayerChannel,
        payload: 'suhoor_reminder',
      );
    }
  }

  /// Show an immediate notification (for streaks, achievements, etc.)
  static Future<void> showMotivation({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: _motivationChannel,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: 400,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'motivation',
    );
  }

  /// Cancel all prayer reminder notifications.
  static Future<void> cancelPrayerReminders() async {
    for (int i = 100; i <= 305; i++) {
      await _plugin.cancel(id: i);
    }
  }

  /// Cancel all notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Fire-and-forget delayed show. Uses Future.delayed for same-day scheduling.
  static void _scheduleDelayedShow({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AndroidNotificationDetails channel,
    String? payload,
  }) {
    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;

    Future.delayed(delay, () async {
      final details = NotificationDetails(
        android: channel,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      try {
        await _plugin.show(
          id: id,
          title: title,
          body: body,
          notificationDetails: details,
          payload: payload,
        );
      } catch (_) {
        // Notification system unavailable
      }
    });
  }
}

// ── Riverpod provider that auto-schedules notifications when prayer times change ──
final notificationServiceProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<TodayPrayerTimes?>>(prayerTimesProvider, (prev, next) {
    next.whenData((times) {
      if (times != null) {
        NotificationService.schedulePrayerReminders(times);
      }
    });
  });
});
