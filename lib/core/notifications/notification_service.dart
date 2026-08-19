import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _dailyChannel = 'goldz_daily';
  static const _alertChannel = 'goldz_alerts';
  static const _newsChannel = 'goldz_news';

  static const idDaily = 1001;
  static const idMove = 1002;
  static const idNews = 1003;

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await _deviceTimezone()));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: InitializationSettings(android: androidSettings, iOS: darwinSettings),
    );

    await _createChannels();
  }

  /// flutter_timezone changed its return type across versions — older
  /// releases give a String, newer ones a TimezoneInfo object. Reading it
  /// dynamically works with either, and falls back if anything goes wrong.
  Future<String> _deviceTimezone() async {
    try {
      final dynamic zone = await FlutterTimezone.getLocalTimezone();
      if (zone is String) return zone;
      final dynamic identifier = zone.identifier;
      if (identifier is String && identifier.isNotEmpty) return identifier;
    } catch (_) {
      // fall through
    }
    return 'Africa/Cairo';
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  Future<void> _createChannels() async {
    final android = _android;
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _dailyChannel,
        'Daily summary',
        description: 'Your daily gold price update',
        importance: Importance.defaultImportance,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _alertChannel,
        'Price alerts',
        description: 'Significant price movements',
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _newsChannel,
        'News',
        description: 'Breaking gold and currency news',
        importance: Importance.defaultImportance,
      ),
    );
  }

  /// Ask only when the user switches something ON — never at first launch.
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        return await _android?.requestNotificationsPermission() ?? false;
      }
      return await _ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    } catch (_) {
      return false;
    }
  }

  NotificationDetails _details(String channelId, String channelName, {bool high = false}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: high ? Importance.high : Importance.defaultImportance,
        priority: high ? Priority.high : Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  // ──────────────── Daily summary ────────────────

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id: idDaily,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: _details(_dailyChannel, 'Daily summary'),
      // Inexact avoids the restricted SCHEDULE_EXACT_ALARM permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Repeats every day at this clock time.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDaily() => _plugin.cancel(id: idDaily);

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ──────────────── Instant ────────────────

  Future<void> showMoveAlert(String title, String body) => _plugin.show(
        id: idMove,
        title: title,
        body: body,
        notificationDetails: _details(_alertChannel, 'Price alerts', high: true),
      );

  Future<void> showNewsAlert(String title, String body) => _plugin.show(
        id: idNews,
        title: title,
        body: body,
        notificationDetails: _details(_newsChannel, 'News'),
      );

  static bool get isQuietHours {
    final hour = DateTime.now().hour;
    return hour >= 23 || hour < 7;
  }
}