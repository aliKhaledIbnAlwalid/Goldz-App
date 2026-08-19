import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/market_category/category_cubit.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/price_item.dart';
import '../cubit/market_cubit.dart';
import '../cubit/market_state.dart';
import '../utils/asset_labels.dart';
import '../widgets/category_tabs.dart';
import '../widgets/sparkline.dart';

enum _SortMode { purity, traded }

class AllPricesScreen extends StatefulWidget {
  const AllPricesScreen({super.key});

  @override
  State<AllPricesScreen> createState() => _AllPricesScreenState();
}

class _AllPricesScreenState extends State<AllPricesScreen> {
  _SortMode _sort = _SortMode.purity;

  List<PriceItem> _sorted(List<PriceItem> items, MarketCategory category) {
    final list = [...items];
    if (_sort == _SortMode.purity) {
      list.sort((a, b) => b.usdValue.compareTo(a.usdValue));
    } else {
      list.sort((a, b) => popularityRank(category, a.id)
          .compareTo(popularityRank(category, b.id)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return BlocBuilder<CategoryCubit, MarketCategory>(
      builder: (context, category) {
        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              context.l10n.allTitle(categoryLabel(context, category)),
              style: AppText.heading(19, color: c.brass),
            ),
            actions: [
              BlocBuilder<CurrencyCubit, AppCurrency>(
                builder: (context, currency) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 18),
                  child: Center(
                    child: Text(
                      currency.code,
                      style: AppText.label(12.5,
                          color: c.textSecondary, weight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<CurrencyCubit, AppCurrency>(
            builder: (context, currency) {
              return BlocBuilder<MarketCubit, MarketState>(
                builder: (context, market) {
                  final snapshot = market.snapshot;

                  if (snapshot == null) {
                    return Center(
                      child: market.isLoading
                          ? CircularProgressIndicator(color: c.brass)
                          : Text(
                              market.error ?? context.l10n.nothingToShow,
                              style: AppText.label(14,
                                  color: c.textSecondary),
                            ),
                    );
                  }

                  final items = _sorted(snapshot.of(category), category);
                  final rate =
                      snapshot.rateFor(currency.code, currency.perUsd);

                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: CategoryTabs(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Row(
                          children: [
                            _sortChip(
                                context.l10n.highestPurity, _SortMode.purity),
                            const SizedBox(width: 10),
                            _sortChip(
                                context.l10n.mostTraded, _SortMode.traded),
                          ],
                        ),
                      ),
                      if (items.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              context.l10n.nothingToShow,
                              style: AppText.label(14,
                                  color: c.textSecondary),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) => _PriceRow(
                              item: items[i],
                              category: category,
                              currencyCode: currency.code,
                              rate: rate,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _sortChip(String label, _SortMode mode) {
    final c = context.c;
    final selected = _sort == mode;

    return GestureDetector(
      onTap: () => setState(() => _sort = mode),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.textPrimary : c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? c.textPrimary : c.border),
        ),
        child: Text(
          label,
          style: AppText.label(12.5,
              color: selected ? c.surface : c.textSecondary,
              weight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final PriceItem item;
  final MarketCategory category;
  final String currencyCode;
  final double rate;

  const _PriceRow({
    required this.item,
    required this.category,
    required this.currencyCode,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasChange = item.hasChange;
    final isDown = hasChange && !item.isPositive;
    final trendColor =
        !hasChange ? c.textMuted : (isDown ? c.negative : c.positive);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDown ? c.surfaceAlt : c.brass,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                item.badge,
                style: AppText.label(13,
                    color: isDown ? c.textPrimary : c.onBrass,
                    weight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assetDescriptor(context, category, item.id),
                    style: AppText.micro(9.5, color: c.textMuted)),
                const SizedBox(height: 4),
                Text(formatPrice(item.valueIn(rate)),
                    style: AppText.price(21, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text('$currencyCode ${item.unit}'.trim(),
                    style: AppText.label(11, color: c.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.hasTrend)
                SizedBox(
                  width: 58,
                  height: 24,
                  child: Sparkline(data: item.trend, color: trendColor),
                ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: !hasChange
                      ? c.surfaceAlt
                      : (isDown ? c.negativeSoft : c.positiveSoft),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  hasChange
                      ? '${isDown ? '↓' : '↑'} ${formatPercentOrNull(item.changePercent)}'
                      : '—',
                  style: AppText.label(10.5,
                      color: trendColor, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}