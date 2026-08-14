import 'package:dartz/dartz.dart';
import 'package:goldz/features/gold_prices/domain/entities/market_snapshot.dart';
import '../../../../core/errors/failures.dart';
abstract class MarketRepository {
  Future<Either<Failure, MarketSnapshot>> getSnapshot({
    bool forceRefresh = false,
  });
}