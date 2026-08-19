import 'package:equatable/equatable.dart';

enum MarketCategory { gold, silver, currency, all }

extension MarketCategoryX on MarketCategory {
  String get label => switch (this) {
        MarketCategory.gold => 'Gold',
        MarketCategory.silver => 'Silver',
        MarketCategory.currency => 'Currency',
    // TODO: Handle this case.
    MarketCategory.all => throw UnimplementedError(),
      };

  String get sectionTitle => switch (this) {
        MarketCategory.gold => 'KARATS',
        MarketCategory.silver => 'PURITIES',
        MarketCategory.currency => 'RATES',
    // TODO: Handle this case.
    MarketCategory.all => throw UnimplementedError(),
      };
}

class PriceItem extends Equatable {
  final String id;
  final String label;
  final String badge;

  /// Canonical value in USD — converted to any currency at display time.
  final double usdValue;

  final String unit;

  /// NULLABLE on purpose: null means "we don't have a change figure".
  /// The UI shows "—" instead of inventing a number.
  final double? changePercent;

  final List<double> trend;

  const PriceItem({
    required this.id,
    required this.label,
    required this.badge,
    required this.usdValue,
    required this.unit,
    required this.changePercent,
    required this.trend,
  });

  bool get hasChange => changePercent != null;
  bool get isPositive => (changePercent ?? 0) >= 0;
  bool get hasTrend => trend.length >= 2;

  double valueIn(double perUsd) => usdValue * perUsd;

  @override
  List<Object?> get props => [id, usdValue, changePercent, trend];
}