import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/core/theme/app_palette.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';

import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/price_item.dart';
import '../cubit/market_cubit.dart';
import '../cubit/market_state.dart';
import '../utils/asset_labels.dart';
import '../widgets/sparkline.dart';

enum _SortMode { purity, traded }

class AllPricesScreen extends StatefulWidget {
  final MarketCategory category;

  const AllPricesScreen({super.key, required this.category});

  @override
  State<AllPricesScreen> createState() => _AllPricesScreenState();
}

class _AllPricesScreenState extends State<AllPricesScreen> {
  _SortMode _sort = _SortMode.purity;

  List<PriceItem> _sorted(List<PriceItem> items) {
    final list = [...items];
    if (_sort == _SortMode.purity) {
      list.sort((a, b) => b.usdValue.compareTo(a.usdValue));
    } else {
      list.sort((a, b) => popularityRank(widget.category, a.id)
          .compareTo(popularityRank(widget.category, b.id)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.background,
      appBar: AppBar(
        title: Text('All ${widget.category.label}',
            style: AppText.heading(19, color: context.c.brass)),
        actions: [
          BlocBuilder<CurrencyCubit, AppCurrency>(
            builder: (context, currency) => Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Center(
                child: Text(currency.code,
                    style: AppText.label(12.5,
                        color: context.c.textSecondary,
                        weight: FontWeight.w700)),
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
                      ? CircularProgressIndicator(color: context.c.brass)
                      : Text(market.error ?? 'No data available.',
                          style: AppText.label(14, color: context.c.brass)),
                );
              }

              final items = _sorted(snapshot.of(widget.category));
              if (items.isEmpty) {
                return Center(
                    child: Text('Nothing to show yet.',
                        style: AppText.label(14, color: context.c.brass)));
              }

              final rate = snapshot.rateFor(currency.code, currency.perUsd);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Row(
                      children: [
                        _sortChip('Highest Purity', _SortMode.purity),
                        const SizedBox(width: 10),
                        _sortChip('Most Traded', _SortMode.traded),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _PriceRow(
                        item: items[i],
                        category: widget.category,
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
  }

  Widget _sortChip(String label, _SortMode mode) {
    final selected = _sort == mode;
    return GestureDetector(
      onTap: () => setState(() => _sort = mode),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.c.textMuted : context.c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? context.c.textMuted : context.c.border,
          ),
        ),
        child: Text(label,
            style: AppText.label(12.5,
                color: selected ? Colors.white : context.c.textSecondary,
                weight: FontWeight.w600)),
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
    final hasChange = item.hasChange;
    final trendColor = !hasChange
        ? context.c.textMuted
        : (item.isPositive ? context.c.positive : context.c.negative);
    final isDown = hasChange && !item.isPositive;

    return Container(
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.c.border),
        // Red edge accent on losers — a subtle scannable cue.
        gradient: isDown
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [context.c.negative, context.c.surface],
                stops: const [0.012, 0.012],
              )
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hasChange && !item.isPositive
                  ? context.c.surfaceAlt
                  : context.c.brass,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                item.badge,
                style: AppText.label(13,
                    color: hasChange && !item.isPositive
                        ? context.c.textMuted
                        : Colors.white,
                    weight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assetDescriptor(category, item.id),
                    style: AppText.micro(9.5, color: context.c.brass)),
                const SizedBox(height: 4),
                Text(formatPrice(item.valueIn(rate)),
                    style: AppText.price(21, color: context.c.textMuted)),
                const SizedBox(height: 2),
                Text(
                  '$currencyCode ${item.unit}'.trim(),
                  style: AppText.label(11, color: context.c.textMuted),
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: !hasChange
                      ? context.c.surfaceAlt
                      : (item.isPositive
                          ? context.c.positiveSoft
                          : context.c.negativeSoft),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  hasChange
                      ? '${item.isPositive ? '↑' : '↓'} ${formatPercentOrNull(item.changePercent)}'
                      : '— 0.0%',
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
