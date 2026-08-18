import '../../domain/entities/price_item.dart';

/// Human-friendly descriptors — what each purity is actually used for.
String assetDescriptor(MarketCategory category, String id) {
  switch (category) {
    case MarketCategory.gold:
      return switch (id) {
        '24' => 'RAW GOLD',
        '22' => 'STANDARD',
        '21' => 'POPULAR JEWELRY',
        '18' => 'FINE JEWELRY',
        '14' => 'ALLOY',
        '12' => 'LOW ALLOY',
        '10' => 'BUDGET ALLOY',
        '9' => 'MINIMUM PURITY',
        _ => 'GOLD',
      };
    case MarketCategory.silver:
      return switch (id) {
        '999' => 'FINE SILVER',
        '958' => 'BRITANNIA',
        '925' => 'STERLING',
        '800' => 'LOW GRADE',
        _ => 'SILVER',
      };
    case MarketCategory.currency:
      return 'EXCHANGE RATE';
  }
}

/// Trading popularity in the Egyptian market — used for the
/// "Most Traded" sort option.
const _goldPopularity = ['21', '18', '24', '22', '14', '12', '10', '9'];
const _silverPopularity = ['925', '999', '958', '800'];
const _currencyPopularity = ['USD', 'SAR', 'EUR', 'AED', 'GBP', 'KWD'];

int popularityRank(MarketCategory category, String id) {
  final list = switch (category) {
    MarketCategory.gold => _goldPopularity,
    MarketCategory.silver => _silverPopularity,
    MarketCategory.currency => _currencyPopularity,
  };
  final index = list.indexOf(id);
  return index == -1 ? 999 : index;
}