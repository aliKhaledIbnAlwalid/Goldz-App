import 'dart:convert';

import 'package:goldz/core/cashe/hive_boxes.dart';
import 'package:goldz/core/errors/exception.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/api_constants.dart';

abstract class MarketLocalDataSource {
  Future<void> cacheMarket({
    required Map<String, dynamic> gold,
    Map<String, dynamic>? silver,
  });
  Future<void> cacheFx(Map<String, dynamic> fx);

  Map<String, dynamic>? readGold();
  Map<String, dynamic>? readSilver();
  Map<String, dynamic>? readFx();

  DateTime? get savedAt;
  DateTime? get fxSavedAt;
  @override
  bool get hasCache => readGold() != null; 

  /// Appends an observed price point (throttled).
  Future<void> recordPoint({required double goldOz, double? silverOz});
  List<Map<String, dynamic>> readHistory();
}

class MarketLocalDataSourceImpl implements MarketLocalDataSource {
  final Box box;
  MarketLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheMarket({
    required Map<String, dynamic> gold,
    Map<String, dynamic>? silver,
  }) async {
    try {
      await box.putAll({
        HiveBoxes.keyGold: jsonEncode(gold),
        if (silver != null) HiveBoxes.keySilver: jsonEncode(silver),
        HiveBoxes.keySavedAt: DateTime.now().toIso8601String(),
      });
    } catch (_) {
      throw const CacheException('Could not save prices offline.');
    }
  }

  @override
  Future<void> cacheFx(Map<String, dynamic> fx) async {
    try {
      await box.putAll({
        HiveBoxes.keyFx: jsonEncode(fx),
        HiveBoxes.keyFxSavedAt: DateTime.now().toIso8601String(),
      });
    } catch (_) {
      throw const CacheException('Could not save exchange rates offline.');
    }
  }

  Map<String, dynamic>? _read(String key) {
    final raw = box.get(key);
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? readGold() => _read(HiveBoxes.keyGold);

  @override
  Map<String, dynamic>? readSilver() => _read(HiveBoxes.keySilver);

  @override
  Map<String, dynamic>? readFx() => _read(HiveBoxes.keyFx);

  DateTime? _date(String key) {
    final raw = box.get(key);
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  @override
  DateTime? get savedAt => _date(HiveBoxes.keySavedAt);

  @override
  DateTime? get fxSavedAt => _date(HiveBoxes.keyFxSavedAt);

  @override
  bool get hasCache => readGold() != null && readFx() != null;

  // ───────────── local price history ─────────────

  @override
  List<Map<String, dynamic>> readHistory() {
    final raw = box.get(HiveBoxes.keyHistory);
    if (raw is! String) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map(Map<String, dynamic>.from).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> recordPoint({
    required double goldOz,
    double? silverOz,
  }) async {
    final history = readHistory();
    final now = DateTime.now();

    // Throttle: don't spam a point on every app open.
    if (history.isNotEmpty) {
      final lastAt = DateTime.tryParse(history.last['t']?.toString() ?? '');
      if (lastAt != null &&
          now.difference(lastAt) < ApiConstants.historyInterval) {
        return;
      }
    }

    history.add({
      't': now.toIso8601String(),
      'g': goldOz,
      if (silverOz != null) 's': silverOz,
    });

    // Keep the list bounded so the box never grows without limit.
    final trimmed = history.length > ApiConstants.historyMaxPoints
        ? history.sublist(history.length - ApiConstants.historyMaxPoints)
        : history;

    try {
      await box.put(HiveBoxes.keyHistory, jsonEncode(trimmed));
    } catch (_) {
      // History is a nice-to-have — never break prices over it.
    }
  }
}
