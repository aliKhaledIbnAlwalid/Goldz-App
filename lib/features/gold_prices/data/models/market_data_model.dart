import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/price_item.dart';

class MarketDataModel {
  final double goldUsdOz;
  final double? silverUsdOz;
  final Map<String, double> fxRates;
  final DateTime updatedAt;

  const MarketDataModel({
    required this.goldUsdOz,
    required this.silverUsdOz,
    required this.fxRates,
    required this.updatedAt,
  });

  double get goldGramUsd => goldUsdOz / ApiConstants.gramsPerTroyOunce;

  static double? _n(dynamic v) => v is num ? v.toDouble() : null;

  /// Tolerant extraction — providers name this field differently.
  /// If the shape ever changes, this keeps working instead of crashing.
  static double? _price(Map<String, dynamic> json) {
    for (final key in ['price', 'rate', 'value', 'last', 'ask', 'close']) {
      final v = _n(json[key]);
      if (v != null && v > 0) return v;
    }
    return null;
  }

  factory MarketDataModel.from({
    required Map<String, dynamic> gold,
    Map<String, dynamic>? silver,
    required Map<String, dynamic> fx,
  }) {
    final goldOz = _price(gold);
    if (goldOz == null) {
      throw const FormatException('Could not read gold price from response.');
    }

    final rates = <String, double>{'USD': 1.0};
    final raw = fx['rates'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is num) rates[k.toString()] = v.toDouble();
      });
    }

    return MarketDataModel(
      goldUsdOz: goldOz,
      silverUsdOz: silver == null ? null : _price(silver),
      fxRates: rates,
      updatedAt: DateTime.now(),
    );
  }

  // ─────────────── GOLD: karat K = pure × (K / 24) ───────────────

  static const _karats = [24, 22, 21, 18, 14, 12, 10, 9];

  List<PriceItem> goldItems({
    required List<double> trend,
    required double? changePercent,
  }) {
    return _karats
        .map((k) => PriceItem(
              id: '$k',
              label: 'Karat $k',
              badge: '$k',
              usdValue: goldGramUsd * (k / 24),
              unit: '/ g',
              changePercent: changePercent,
              trend: trend,
            ))
        .toList();
  }

  // ─────────────── SILVER: purity out of 1000 ───────────────

  static const _purities = <String, double>{
    '999': 0.999,
    '958': 0.958,
    '925': 0.925,
    '800': 0.800,
  };

  static const _purityLabels = <String, String>{
    '999': 'Silver 999',
    '958': 'Silver 958',
    '925': 'Sterling 925',
    '800': 'Silver 800',
  };

  List<PriceItem> silverItems({
    required List<double> trend,
    required double? changePercent,
  }) {
    final oz = silverUsdOz;
    if (oz == null || oz <= 0) return const [];

    final pureGram = oz / ApiConstants.gramsPerTroyOunce;

    return _purities.entries
        .map((e) => PriceItem(
              id: e.key,
              label: _purityLabels[e.key]!,
              badge: e.key,
              usdValue: pureGram * e.value,
              unit: '/ g',
              changePercent: changePercent,
              trend: trend,
            ))
        .toList();
  }

  // ─────────────── CURRENCY ───────────────

  static const _displayed = <String, String>{
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'SAR': 'Saudi Riyal',
    'AED': 'UAE Dirham',
    'KWD': 'Kuwaiti Dinar',
    'EGP': 'Egyptian Pound',
    'TRY': 'Turkish Lira',
  };

  static const _badges = <String, String>{
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'SAR': 'SR',
    'AED': 'AED',
    'KWD': 'KD',
    'EGP': 'EG',
    'TRY': '₺',
  };

  List<PriceItem> currencyItems() {
    final items = <PriceItem>[];

    _displayed.forEach((code, name) {
      final perUsd = fxRates[code];
      if (perUsd == null || perUsd <= 0) return;

      items.add(PriceItem(
        id: code,
        label: name,
        badge: _badges[code] ?? code,
        usdValue: 1 / perUsd, // value of 1 unit, in USD
        unit: '',
        changePercent: null, // this endpoint gives no daily change
        trend: const [],
      ));
    });

    return items;
  }
}