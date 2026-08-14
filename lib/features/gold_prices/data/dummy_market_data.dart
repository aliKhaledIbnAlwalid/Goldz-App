import '../domain/entities/price_item.dart';

class DummyMarketData {
  DummyMarketData._();

  static const _trendUp = [3.0, 3.4, 3.2, 3.9, 3.6, 4.2, 3.9, 4.6, 4.3, 4.9, 5.2];
  static const _trendSoft = [2.0, 2.3, 2.1, 2.6, 2.4, 2.9, 3.1];
  static const _trendFlat = [3.0, 3.1, 2.9, 3.2, 3.0, 3.3, 3.2];

  // ── Gold: value per GRAM in USD ──
  static const gold = <PriceItem>[
    PriceItem(id: '24', label: 'Karat 24', badge: '24', usdValue: 127.29,
        unit: '/ g', changePercent: 0.90, trend: _trendUp),
    PriceItem(id: '22', label: 'Karat 22', badge: '22', usdValue: 116.68,
        unit: '/ g', changePercent: 0.80, trend: _trendUp),
    PriceItem(id: '21', label: 'Karat 21', badge: '21', usdValue: 111.37,
        unit: '/ g', changePercent: 0.82, trend: _trendUp),
    PriceItem(id: '18', label: 'Karat 18', badge: '18', usdValue: 95.46,
        unit: '/ g', changePercent: 0.70, trend: _trendSoft),
    PriceItem(id: '14', label: 'Karat 14', badge: '14', usdValue: 74.25,
        unit: '/ g', changePercent: 0.60, trend: _trendSoft),
    PriceItem(id: '12', label: 'Karat 12', badge: '12', usdValue: 63.64,
        unit: '/ g', changePercent: 0.50, trend: _trendFlat),
    PriceItem(id: '9', label: 'Karat 9', badge: '9', usdValue: 47.73,
        unit: '/ g', changePercent: 0.40, trend: _trendFlat),
  ];

  // ── Silver: value per GRAM in USD ──
  static const silver = <PriceItem>[
    PriceItem(id: '999', label: 'Silver 999', badge: '999', usdValue: 1.62,
        unit: '/ g', changePercent: 0.50, trend: _trendUp),
    PriceItem(id: '958', label: 'Silver 958', badge: '958', usdValue: 1.55,
        unit: '/ g', changePercent: 0.45, trend: _trendSoft),
    PriceItem(id: '925', label: 'Sterling 925', badge: '925', usdValue: 1.50,
        unit: '/ g', changePercent: 0.40, trend: _trendSoft),
    PriceItem(id: '800', label: 'Silver 800', badge: '800', usdValue: 1.30,
        unit: '/ g', changePercent: -0.20, trend: _trendFlat),
  ];

  // ── Currency: value of 1 unit in USD ──
  static const currency = <PriceItem>[
    PriceItem(id: 'USD', label: 'US Dollar', badge: '\$', usdValue: 1.0,
        unit: '', changePercent: 0.10, trend: _trendFlat),
    PriceItem(id: 'EUR', label: 'Euro', badge: '€', usdValue: 1.17,
        unit: '', changePercent: 0.22, trend: _trendUp),
    PriceItem(id: 'GBP', label: 'British Pound', badge: '£', usdValue: 1.35,
        unit: '', changePercent: 0.18, trend: _trendUp),
    PriceItem(id: 'SAR', label: 'Saudi Riyal', badge: 'SR', usdValue: 0.2667,
        unit: '', changePercent: 0.02, trend: _trendFlat),
    PriceItem(id: 'AED', label: 'UAE Dirham', badge: 'AED', usdValue: 0.2723,
        unit: '', changePercent: 0.03, trend: _trendFlat),
    PriceItem(id: 'KWD', label: 'Kuwaiti Dinar', badge: 'KD', usdValue: 3.26,
        unit: '', changePercent: -0.05, trend: _trendSoft),
  ];

  static List<PriceItem> of(MarketCategory category) => switch (category) {
        MarketCategory.gold => gold,
        MarketCategory.silver => silver,
        MarketCategory.currency => currency,
      };

  /// The item shown in the big hero card.
  static PriceItem headline(MarketCategory category) => switch (category) {
        MarketCategory.gold => gold.firstWhere((e) => e.id == '21'),
        MarketCategory.silver => silver.firstWhere((e) => e.id == '925'),
        MarketCategory.currency => currency.first,
      };

  static const gramsPerOunce = 31.1035;
}