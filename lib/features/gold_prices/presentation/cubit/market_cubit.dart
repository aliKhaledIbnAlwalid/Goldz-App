import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_market_snapshot.dart';
import 'market_state.dart';

class MarketCubit extends Cubit<MarketState> {
  final GetMarketSnapshot getMarketSnapshot;

  MarketCubit(this.getMarketSnapshot) : super(const MarketState());

  /// [forceRefresh] bypasses the cache TTL — used by pull-to-refresh.
  Future<void> load({bool forceRefresh = false}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await getMarketSnapshot(forceRefresh: forceRefresh);

    result.fold(
      // Keep whatever data we already have — just surface the error.
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (snapshot) => emit(MarketState(snapshot: snapshot, isLoading: false)),
    );
  }
}