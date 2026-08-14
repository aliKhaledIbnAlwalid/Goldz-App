import 'package:dartz/dartz.dart';
import 'package:goldz/features/gold_prices/data/repositories/market_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/market_snapshot.dart';

class GetMarketSnapshot {
  final MarketRepository repository;
  GetMarketSnapshot(this.repository);

  Future<Either<Failure, MarketSnapshot>> call({bool forceRefresh = false}) {
    return repository.getSnapshot(forceRefresh: forceRefresh);
  }
}