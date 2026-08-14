import 'package:dio/dio.dart';
import 'package:goldz/core/errors/exception.dart';

import '../../../../core/constants/api_constants.dart';

abstract class MarketRemoteDataSource {
  Future<Map<String, dynamic>> fetchGold();
  Future<Map<String, dynamic>> fetchSilver();
  Future<Map<String, dynamic>> fetchFx();
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final Dio dio;
  MarketRemoteDataSourceImpl(this.dio);

  final Map<String, DateTime> _cooldowns = {};

  @override
  Future<Map<String, dynamic>> fetchGold() => _withFallback(
        primary: () => _get(ApiConstants.goldUrl, 'gold'),
        backup: () async => _normalizeGoldPriceDev(
          await _get(ApiConstants.goldFallbackUrl, 'gold-backup'),
        ),
      );

  @override
  Future<Map<String, dynamic>> fetchSilver() => _withFallback(
        primary: () => _get(ApiConstants.silverUrl, 'silver'),
        backup: () async => _normalizeGoldPriceDev(
          await _get(ApiConstants.silverFallbackUrl, 'silver-backup'),
        ),
      );

  @override
  Future<Map<String, dynamic>> fetchFx() => _withFallback(
        primary: () => _get(ApiConstants.fxUrl, 'fx'),
        backup: () => _get(ApiConstants.fxFallbackUrl, 'fx-backup'),
      );

  Future<Map<String, dynamic>> _withFallback({
    required Future<Map<String, dynamic>> Function() primary,
    required Future<Map<String, dynamic>> Function() backup,
  }) async {
    try {
      return await primary();
    } catch (_) {
      return backup();
    }
  }

  /// goldprice.dev returns { "symbols": [ { "price": 4368.0, ... } ] }
  /// Flatten it to the shape our model expects.
  Map<String, dynamic> _normalizeGoldPriceDev(Map<String, dynamic> raw) {
    final symbols = raw['symbols'];
    if (symbols is List && symbols.isNotEmpty) {
      final first = symbols.first;
      if (first is Map && first['price'] is num) {
        return {'price': (first['price'] as num).toDouble()};
      }
    }
    throw const ServerException('Unexpected backup response shape.');
  }

  Future<Map<String, dynamic>> _get(
    String url,
    String label, {
    int attempt = 0,
  }) async {
    final until = _cooldowns[label];
    if (until != null && DateTime.now().isBefore(until)) {
      throw ServerException('$label cooling down after rate limit.');
    }

    try {
      final response = await dio.get(url);
      final status = response.statusCode ?? 0;

      if (status == 429) {
        final wait = _retryAfter(response);

        // One polite retry if the server tells us to wait briefly.
        if (attempt == 0 && wait != null && wait.inSeconds <= 5) {
          await Future.delayed(wait);
          return _get(url, label, attempt: 1);
        }

        _cooldowns[label] =
            DateTime.now().add(wait ?? ApiConstants.rateLimitCooldown);
        throw ServerException('Rate limited by $label.');
      }

      if (status >= 400) {
        throw ServerException('$label returned HTTP $status.');
      }

      final data = response.data;
      if (data is Map) {
        _cooldowns.remove(label);
        return Map<String, dynamic>.from(data);
      }
      throw ServerException('Unexpected response format from $label.');
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e, label));
    }
  }

  Duration? _retryAfter(Response response) {
    final header = response.headers.value('retry-after');
    if (header == null) return null;
    final seconds = int.tryParse(header);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  String _mapDioError(DioException e, String label) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Connection timed out ($label).',
      DioExceptionType.connectionError => 'No internet connection.',
      _ => 'Could not reach $label.',
    };
  }
}