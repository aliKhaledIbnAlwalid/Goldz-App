import 'package:dartz/dartz.dart';
import 'package:goldz/core/errors/exception.dart';
import 'package:goldz/features/gold_prices/data/repositories/market_repository.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/market_snapshot.dart';
import '../datasources/market_local_datasource.dart';
import '../datasources/market_remote_datasource.dart';
import '../models/market_data_model.dart';

typedef SnapshotResult = Either<Failure, MarketSnapshot>;

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remote;
  final MarketLocalDataSource local;
  final NetworkInfo networkInfo;

  MarketRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<SnapshotResult> getSnapshot({bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh()) {
      final cached = _fromCache();
      if (cached != null) return _ok(cached);
    }

    final connected = await networkInfo.isConnected;
    if (!connected) {
      final cached = _fromCache();
      if (cached != null) return _ok(cached);
      return _fail(
        const NetworkFailure('You are offline and no saved prices were found.'),
      );
    }

    try {
      // GOLD is the only hard requirement.
      final gold = await remote.fetchGold();

      // SILVER is optional.
      Map<String, dynamic>? silver;
      try {
        silver = await remote.fetchSilver();
      } catch (_) {
        silver = local.readSilver();
      }

      await local.cacheMarket(gold: gold, silver: silver);

      // FX is optional too — cache, then backup source, then
      // built-in fallback rates. Never fatal.
      Map<String, dynamic> fx = const {};
      final cachedFx = local.readFx();

      if (_isFxFresh() && cachedFx != null) {
        fx = cachedFx;
      } else {
        try {
          fx = await remote.fetchFx();
          await local.cacheFx(fx);
        } catch (_) {
          fx = cachedFx ?? const {};
        }
      }

      final snapshot = _build(
        gold: gold,
        silver: silver,
        fx: fx,
        updatedAt: DateTime.now(),
        fromCache: false,
      );

      await local.recordPoint(
        goldOz: _priceFrom(gold) ?? 0,
        silverOz: silver == null ? null : _priceFrom(silver),
      );

      return _ok(snapshot);
    } on ServerException catch (e) {
      final cached = _fromCache();
      if (cached != null) return _ok(cached);
      return _fail(ServerFailure(e.message));
    } on CacheException catch (e) {
      return _fail(CacheFailure(e.message));
    } catch (_) {
      final cached = _fromCache();
      if (cached != null) return _ok(cached);
      return _fail(const ServerFailure('Could not load prices.'));
    }
  }

  SnapshotResult _ok(MarketSnapshot s) => Right<Failure, MarketSnapshot>(s);
  SnapshotResult _fail(Failure f) => Left<Failure, MarketSnapshot>(f);

  bool _isFresh() {
    final at = local.savedAt;
    if (at == null || !local.hasCache) return false;
    return DateTime.now().difference(at) < ApiConstants.priceTtl;
  }

  bool _isFxFresh() {
    final at = local.fxSavedAt;
    if (at == null || local.readFx() == null) return false;
    return DateTime.now().difference(at) < ApiConstants.fxTtl;
  }

  MarketSnapshot? _fromCache() {
    final gold = local.readGold();
    if (gold == null) return null;

    return _build(
      gold: gold,
      silver: local.readSilver(),
      fx: local.readFx() ?? const {},
      updatedAt: local.savedAt ?? DateTime.now(),
      fromCache: true,
    );
  }

  double _goldOzFrom(Map<String, dynamic> json) => _priceFrom(json) ?? 0;

  double? _priceFrom(Map<String, dynamic> json) {
    for (final key in ['price', 'rate', 'value', 'last', 'ask', 'close']) {
      final v = json[key];
      if (v is num && v > 0) return v.toDouble();
    }
    return null;
  }

  MarketSnapshot _build({
    required Map<String, dynamic> gold,
    Map<String, dynamic>? silver,
    required Map<String, dynamic> fx,
    required DateTime updatedAt,
    required bool fromCache,
  }) {
    final model = MarketDataModel.from(gold: gold, silver: silver, fx: fx);

    final history = local.readHistory();
    final goldTrend = _series(history, 'g');
    final silverTrend = _series(history, 's');

    return MarketSnapshot(
      gold: model.goldItems(
        trend: goldTrend,
        changePercent: _change(goldTrend),
      ),
      silver: model.silverItems(
        trend: silverTrend,
        changePercent: _change(silverTrend),
      ),
      currency: model.currencyItems(),
      fxRates: model.fxRates,
      updatedAt: updatedAt,
      fromCache: fromCache,
    );
  }

  List<double> _series(List<Map<String, dynamic>> history, String key) {
    final values = history
        .map((e) => e[key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .where((e) => e > 0)
        .toList();

    return values.length <= 20 ? values : values.sublist(values.length - 20);
  }

  double? _change(List<double> series) {
    if (series.length < 2) return null;
    final first = series.first;
    if (first == 0) return null;
    return (series.last - first) / first * 100;
  }
}
