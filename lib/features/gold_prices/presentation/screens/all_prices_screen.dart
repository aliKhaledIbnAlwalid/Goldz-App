import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/price_item.dart';
import '../cubit/market_cubit.dart';
import '../cubit/market_state.dart';
import '../widgets/sparkline.dart';

class AllPricesScreen extends StatelessWidget {
  final MarketCategory category;

  const AllPricesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'All ${category.label}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          BlocBuilder<CurrencyCubit, AppCurrency>(
            builder: (context, currency) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${currency.flag}  ${currency.code}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
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
                      ? const CircularProgressIndicator(
                          color: AppColors.gold)
                      : Text(
                          market.error ?? 'No data available.',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                );
              }

              final items = snapshot.of(category);
              if (items.isEmpty) {
                return const Center(
                  child: Text('Nothing to show yet.',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }

              final rate =
                  snapshot.rateFor(currency.code, currency.perUsd);

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _PriceRow(
                  item: items[i],
                  currencyCode: currency.code,
                  rate: rate,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final PriceItem item;
  final String currencyCode;
  final double rate;

  const _PriceRow({
    required this.item,
    required this.currencyCode,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = !item.hasChange
        ? AppColors.textMuted
        : (item.isPositive ? AppColors.positive : AppColors.negative);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                colors: [AppColors.goldSoft, AppColors.goldDark],
              ),
            ),
            child: Center(
              child: Text(
                item.badge,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3B2A08),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 3),
                Text(
                  '${formatPrice(item.valueIn(rate))} '
                  '$currencyCode ${item.unit}'
                      .trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.hasTrend)
                SizedBox(
                  width: 62,
                  height: 26,
                  child: Sparkline(data: item.trend, color: trendColor),
                ),
              const SizedBox(height: 6),
              Text(
                formatPercentOrNull(item.changePercent) ?? '—',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}