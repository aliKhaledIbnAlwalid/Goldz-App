import 'package:hive_flutter/hive_flutter.dart';

/// User's notification choices, persisted in the existing Hive box.
class NotificationPrefs {
  final Box box;
  NotificationPrefs(this.box);

  static const _keyDaily = 'notif_daily_enabled';
  static const _keyDailyHour = 'notif_daily_hour';
  static const _keyDailyMinute = 'notif_daily_minute';
  static const _keyMove = 'notif_move_enabled';
  static const _keyNews = 'notif_news_enabled';
  static const _keyLastMoveAt = 'notif_last_move_at';

  // Daily summary is the only one ON by default — it's the one users want.
  bool get dailyEnabled => box.get(_keyDaily, defaultValue: true) as bool;
  int get dailyHour => box.get(_keyDailyHour, defaultValue: 10) as int;
  int get dailyMinute => box.get(_keyDailyMinute, defaultValue: 0) as int;

  bool get moveEnabled => box.get(_keyMove, defaultValue: false) as bool;
  bool get newsEnabled => box.get(_keyNews, defaultValue: false) as bool;

  DateTime? get lastMoveAlertAt {
    final raw = box.get(_keyLastMoveAt);
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  Future<void> setDaily(bool enabled) => box.put(_keyDaily, enabled);

  Future<void> setDailyTime(int hour, int minute) =>
      box.putAll({_keyDailyHour: hour, _keyDailyMinute: minute});

  Future<void> setMove(bool enabled) => box.put(_keyMove, enabled);

  Future<void> setNews(bool enabled) => box.put(_keyNews, enabled);

  Future<void> markMoveAlertSent() =>
      box.put(_keyLastMoveAt, DateTime.now().toIso8601String());

  /// Rate limit: at most one move alert per 6 hours.
  bool get canSendMoveAlert {
    final last = lastMoveAlertAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= const Duration(hours: 6);
  }
}