import 'package:equatable/equatable.dart';
import 'price_item.dart';

class MarketSnapshot extends Equatable {
  final List<PriceItem> gold;
  final List<PriceItem> silver;
  final List<PriceItem> currency;

  /// How many units of each currency equal 1 USD. e.g. {'EGP': 49.2}
  final Map<String, double> fxRates;

  final DateTime updatedAt;

  /// True when this data came from disk instead of the network.
  final bool fromCache;

  const MarketSnapshot({
    required this.gold,
    required this.silver,
    required this.currency,
    required this.fxRates,
    required this.updatedAt,
    required this.fromCache,
  });

  List<PriceItem> of(MarketCategory category) => switch (category) {
        MarketCategory.gold => gold,
        MarketCategory.silver => silver,
        MarketCategory.currency => currency,
      };

  PriceItem headline(MarketCategory category) => switch (category) {
        MarketCategory.gold =>
          gold.firstWhere((e) => e.id == '21', orElse: () => gold.first),
        MarketCategory.silver =>
          silver.firstWhere((e) => e.id == '925', orElse: () => silver.first),
        MarketCategory.currency => currency.first,
      };

  /// Conversion rate for a currency code, with a safe fallback.
  double rateFor(String code, double fallback) => fxRates[code] ?? fallback;

  MarketSnapshot copyWith({bool? fromCache}) => MarketSnapshot(
        gold: gold,
        silver: silver,
        currency: currency,
        fxRates: fxRates,
        updatedAt: updatedAt,
        fromCache: fromCache ?? this.fromCache,
      );

  @override
  List<Object?> get props => [updatedAt, fromCache, gold, silver, currency];
}