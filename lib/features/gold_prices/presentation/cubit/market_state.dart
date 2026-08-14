import 'package:equatable/equatable.dart';
import '../../domain/entities/market_snapshot.dart';

class MarketState extends Equatable {
  final MarketSnapshot? snapshot;
  final bool isLoading;
  final String? error;

  const MarketState({
    this.snapshot,
    this.isLoading = false,
    this.error,
  });

  bool get hasData => snapshot != null;

  /// True when we're showing saved data because the network failed.
  bool get isStale => snapshot?.fromCache ?? false;

  MarketState copyWith({
    MarketSnapshot? snapshot,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MarketState(
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [snapshot, isLoading, error];
}