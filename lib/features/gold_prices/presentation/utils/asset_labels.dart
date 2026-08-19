import 'package:flutter/widgets.dart';
import '../../../../core/utils/context_ext.dart';
import '../../domain/entities/price_item.dart';

String categoryLabel(BuildContext context, MarketCategory category) =>
    switch (category) {
      MarketCategory.gold => context.l10n.gold,
      MarketCategory.silver => context.l10n.silver,
      MarketCategory.currency => context.l10n.currency,
    };

String sectionTitle(BuildContext context, MarketCategory category) =>
    switch (category) {
      MarketCategory.gold => context.l10n.otherKarats,
      MarketCategory.silver => context.l10n.otherPurities,
      MarketCategory.currency => context.l10n.otherRates,
     
    };

/// Localized item name — replaces the hardcoded English in the model.
String itemLabel(
    BuildContext context, MarketCategory category, PriceItem item) {
  final l = context.l10n;
  return switch (category) {
    MarketCategory.gold => l.karatLabel(item.id),
    MarketCategory.silver => l.silverLabel(item.id),
    MarketCategory.currency => item.label,
  };
}

String assetDescriptor(
    BuildContext context, MarketCategory category, String id) {
  final l = context.l10n;
  switch (category) {
    case MarketCategory.gold:
      return switch (id) {
        '24' => l.descRawGold,
        '22' => l.descStandard,
        '21' => l.descPopularJewelry,
        '18' => l.descFineJewelry,
        '14' => l.descAlloy,
        '12' => l.descLowAlloy,
        '10' => l.descBudgetAlloy,
        _ => l.descMinimumPurity,
      };
    case MarketCategory.silver:
      return switch (id) {
        '999' => l.descFineSilver,
        '958' => l.descBritannia,
        '925' => l.descSterling,
        _ => l.descLowGrade,
      };
    case MarketCategory.currency:
      return l.descExchangeRate;
    
  }
}

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
