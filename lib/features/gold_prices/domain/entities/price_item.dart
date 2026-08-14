import 'package:equatable/equatable.dart';

enum MarketCategory { gold, silver, currency }

extension MarketCategoryX on MarketCategory {
  String get label => switch (this) {
        MarketCategory.gold => 'Gold',
        MarketCategory.silver => 'Silver',
        MarketCategory.currency => 'Currency',
      };

  /// Section title used above the horizontal list.
  String get sectionTitle => switch (this) {
        MarketCategory.gold => 'KARATS',
        MarketCategory.silver => 'PURITIES',
        MarketCategory.currency => 'RATES',
      };
}

class PriceItem extends Equatable {
  final String id;             // '21'
  final String label;          // 'Karat 21'
  final String badge;          // '21'  (shown in the small gold square)
  final double usdValue;       // canonical value in USD
  final String unit;           // '/ g', '/ oz', or ''
  final double changePercent;  // 0.82
  final List<double> trend;    // sparkline points

  const PriceItem({
    required this.id,
    required this.label,
    required this.badge,
    required this.usdValue,
    required this.unit,
    required this.changePercent,
    required this.trend,
  });

  bool get isPositive => changePercent >= 0;

  /// Converts the canonical USD value into any currency.
  double valueIn(double perUsd) => usdValue * perUsd;

  @override
  List<Object?> get props => [id, usdValue, changePercent];
}