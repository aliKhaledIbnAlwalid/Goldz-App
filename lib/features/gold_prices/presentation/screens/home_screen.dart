import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../news/presentation/widgets/news_section.dart';
import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/market_category/category_cubit.dart';
import '../../../../core/shell/shell_cubit.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/market_snapshot.dart';
import '../../domain/entities/price_item.dart';
import '../cubit/market_cubit.dart';
import '../cubit/market_state.dart';
import '../utils/asset_labels.dart';
import '../widgets/category_tabs.dart';
import '../widgets/currency_sheet.dart';
import '../widgets/karat_card.dart';
import '../widgets/live_price_card.dart';

const _gramsPerOunce = 31.1035;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return BlocBuilder<CategoryCubit, MarketCategory>(
      builder: (context, category) {
        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<CurrencyCubit, AppCurrency>(
              builder: (context, currency) {
                return BlocBuilder<MarketCubit, MarketState>(
                  builder: (context, market) {
                    return RefreshIndicator(
                      color: c.brass,
                      backgroundColor: c.surface,
                      onRefresh: () => context
                          .read<MarketCubit>()
                          .load(forceRefresh: true),
                      child: _buildBody(context, category, currency, market),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── Body ─────────────────────────
  Widget _buildBody(
    BuildContext context,
    MarketCategory category,
    AppCurrency currency,
    MarketState market,
  ) {
    final c = context.c;
    final snapshot = market.snapshot;

    if (snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          _buildHeader(context, currency),
          const SizedBox(height: 90),
          if (market.isLoading)
            Center(child: CircularProgressIndicator(color: c.brass))
          else
            _buildErrorState(context, market.error),
        ],
      );
    }

    final rate = snapshot.rateFor(currency.code, currency.perUsd);
    final items = snapshot.of(category);

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          _buildHeader(context, currency),
          const SizedBox(height: 18),
          const CategoryTabs(),
          const SizedBox(height: 60),
          Center(
            child: Text(
              context.l10n.noDataFor(categoryLabel(context, category)),
              style: AppText.label(14, color: c.textSecondary),
            ),
          ),
        ],
      );
    }

    final headline = snapshot.headline(category);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        _buildHeader(context, currency),
        if (market.isStale || market.error != null) ...[
          const SizedBox(height: 14),
          _buildStatusBanner(context, market),
        ],
        const SizedBox(height: 18),
        const CategoryTabs(),
        const SizedBox(height: 20),
        LivePriceCard(
          assetLabel:
              '${categoryLabel(context, category)} · ${itemLabel(context, category, headline)}',
          price: formatPrice(headline.valueIn(rate)),
          unit: category == MarketCategory.currency
              ? context.l10n.perUnit(currency.code)
              : context.l10n.perGram(currency.code),
          changePercent: formatPercentOrNull(headline.changePercent),
          isPositive: headline.isPositive,
          usdLabel: '~ \$${formatPrice(headline.usdValue)} USD',
          chartData: headline.trend,
          onViewDetails: () => context.read<ShellCubit>().goTo(1),
        ),
        const SizedBox(height: 28),
        Text(
          sectionTitle(context, category),
          style: AppText.heading(21, color: c.textPrimary),
        ),
        const SizedBox(height: 14),
        _buildHorizontalList(context, category, items, currency.code, rate),
        const SizedBox(height: 26),
        _buildStatsGrid(context, category, snapshot, currency, rate),
        const SizedBox(height: 28),
        const NewsSection(),
        const SizedBox(height: 22),
        Center(
          child: Text(
            context.l10n.updatedAgo(formatAgo(context, snapshot.updatedAt)),
            style: AppText.label(11, color: c.textMuted),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  // ───────────────────────── Header ─────────────────────────
  Widget _buildHeader(BuildContext context, AppCurrency currency) {
    final c = context.c;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: c.brass,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text('G', style: AppText.heading(22, color: c.onBrass)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final name =
                  state is AuthSuccess ? state.user.greetingName : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.liveMarket,
                      style: AppText.micro(9.5, color: c.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    name.isEmpty
                        ? context.l10n.appName
                        : context.l10n.greeting(name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading(19, color: c.textPrimary),
                  ),
                ],
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () => showCurrencySheet(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currency.code,
                  style: AppText.label(12,
                      color: c.textPrimary, weight: FontWeight.w700),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 15, color: c.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 24, color: c.textPrimary),
            PositionedDirectional(
              end: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: c.live,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────── Horizontal list ─────────────────────
  Widget _buildHorizontalList(
    BuildContext context,
    MarketCategory category,
    List<PriceItem> items,
    String code,
    double rate,
  ) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return KaratCard(
            badge: category == MarketCategory.currency
                ? item.id
                : '${item.badge}K',
            price: formatPrice(item.valueIn(rate)),
            currencyCode: code,
            change: formatPercentOrNull(item.changePercent),
            isPositive: item.isPositive,
            chartData: item.trend,
          );
        },
      ),
    );
  }

  // ───────────────────────── Stats ─────────────────────────
  Widget _buildStatsGrid(
    BuildContext context,
    MarketCategory category,
    MarketSnapshot snapshot,
    AppCurrency currency,
    double rate,
  ) {
    final stats = _buildStats(context, category, snapshot, currency, rate);
    if (stats.length < 4) return const SizedBox.shrink();

    return Column(
      children: [
        Row(children: [
          Expanded(child: _statCard(context, stats[0])),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, stats[1])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard(context, stats[2])),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, stats[3])),
        ]),
      ],
    );
  }

  PriceItem? _find(List<PriceItem> list, String id) {
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<_Stat> _buildStats(
    BuildContext context,
    MarketCategory category,
    MarketSnapshot snap,
    AppCurrency currency,
    double rate,
  ) {
    final l = context.l10n;
    final code = currency.code;

    switch (category) {
      case MarketCategory.gold:
        final k24 = _find(snap.gold, '24');
        final k21 = _find(snap.gold, '21');
        if (k24 == null || k21 == null) return const [];
        return [
          _Stat(l.globalOunce,
              '\$${formatBig(k24.usdValue * _gramsPerOunce)}', 'USD'),
          _Stat(l.localOunce,
              formatBig(k24.usdValue * _gramsPerOunce * rate), code),
          // Egyptian gold pound = 8 grams of 21K.
          _Stat(l.goldPound, formatBig(k21.usdValue * 8 * rate), code),
          _Stat(l.usdRate, formatPrice(rate), code),
        ];

      case MarketCategory.silver:
        final s999 = _find(snap.silver, '999');
        final s925 = _find(snap.silver, '925');
        if (s999 == null || s925 == null) return const [];
        return [
          _Stat(l.globalOunce,
              '\$${formatPrice(s999.usdValue * _gramsPerOunce)}', 'USD'),
          _Stat(l.localOunce,
              formatBig(s999.usdValue * _gramsPerOunce * rate), code),
          _Stat(l.sterling100g, formatBig(s925.usdValue * 100 * rate), code),
          _Stat(l.usdRate, formatPrice(rate), code),
        ];

      case MarketCategory.currency:
        final usd = _find(snap.currency, 'USD');
        final eur = _find(snap.currency, 'EUR');
        final gbp = _find(snap.currency, 'GBP');
        final sar = _find(snap.currency, 'SAR');
        if (usd == null || eur == null || gbp == null || sar == null) {
          return const [];
        }
        return [
          _Stat(l.usDollar, formatPrice(usd.valueIn(rate)), code),
          _Stat(l.euro, formatPrice(eur.valueIn(rate)), code),
          _Stat(l.britishPound, formatPrice(gbp.valueIn(rate)), code),
          _Stat(l.saudiRiyal, formatPrice(sar.valueIn(rate)), code),
        ];
    }
  }

  Widget _statCard(BuildContext context, _Stat stat) {
    final c = context.c;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                AppText.label(12, color: c.brass, weight: FontWeight.w600),
          ),
          const SizedBox(height: 9),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.price(19, color: c.textPrimary),
          ),
          const SizedBox(height: 3),
          Text(stat.currencyCode,
              style: AppText.label(11, color: c.textMuted)),
        ],
      ),
    );
  }

  // ───────────────────── Status / error ─────────────────────
  Widget _buildStatusBanner(BuildContext context, MarketState market) {
    final c = context.c;
    final isError = market.error != null;
    final color = isError ? c.negative : c.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isError ? c.negativeSoft : c.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.cloud_off_rounded,
              size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              market.error ?? context.l10n.showingSavedPrices,
              style: AppText.label(12, color: color),
            ),
          ),
          if (isError)
            GestureDetector(
              onTap: () =>
                  context.read<MarketCubit>().load(forceRefresh: true),
              child: Text(
                context.l10n.retry,
                style: AppText.label(12,
                    color: c.brass, weight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? error) {
    final c = context.c;

    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration:
              BoxDecoration(color: c.surfaceAlt, shape: BoxShape.circle),
          child: Icon(Icons.wifi_off_rounded, size: 34, color: c.textMuted),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.couldNotLoadPrices,
          textAlign: TextAlign.center,
          style: AppText.heading(20, color: c.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          error ?? context.l10n.offlineMessage,
          textAlign: TextAlign.center,
          style: AppText.label(13, color: c.textSecondary),
        ),
        const SizedBox(height: 22),
        Center(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.read<MarketCubit>().load(forceRefresh: true),
            icon: Icon(Icons.refresh_rounded, size: 17, color: c.brass),
            label: Text(context.l10n.tryAgain,
                style: AppText.micro(11.5, color: c.brass)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: c.brass),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat {
  final String title;
  final String value;
  final String currencyCode;

  const _Stat(this.title, this.value, this.currencyCode);
}