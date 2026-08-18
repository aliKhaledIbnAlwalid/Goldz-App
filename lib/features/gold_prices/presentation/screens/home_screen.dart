import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/core/theme/app_palette.dart';
import 'package:goldz/features/gold_prices/presentation/screens/calculator_screen.dart';
import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/market_snapshot.dart';
import '../../domain/entities/price_item.dart';
import '../cubit/market_cubit.dart';
import '../cubit/market_state.dart';
import '../widgets/currency_sheet.dart';
import '../widgets/karat_card.dart';
import '../widgets/live_price_card.dart';
import 'all_prices_screen.dart';

const _gramsPerOunce = 31.1035;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MarketCategory _category = MarketCategory.gold;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: context.c.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<CurrencyCubit, AppCurrency>(
            builder: (context, currency) {
              return BlocBuilder<MarketCubit, MarketState>(
                builder: (context, market) {
                  return RefreshIndicator(
                    color: context.c.brass,
                    backgroundColor: context.c.surface,
                    onRefresh: () =>
                        context.read<MarketCubit>().load(forceRefresh: true),
                    child: _buildBody(currency, market),
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody(AppCurrency currency, MarketState market) {
    final snapshot = market.snapshot;

    if (snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          _buildHeader(currency),
          const SizedBox(height: 90),
          if (market.isLoading)
            Center(
                child: CircularProgressIndicator(color: context.c.brass))
          else
            _buildErrorState(market.error),
        ],
      );
    }

    final rate = snapshot.rateFor(currency.code, currency.perUsd);
    final items = snapshot.of(_category);

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          _buildHeader(currency),
          const SizedBox(height: 70),
          Center(
            child: Text(
              'No ${_category.label.toLowerCase()} data available.',
              style: AppText.label(14, color: context.c.brass),
            ),
          ),
        ],
      );
    }

    final headline = snapshot.headline(_category);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        _buildHeader(currency),
        if (market.isStale || market.error != null) ...[
          const SizedBox(height: 14),
          _buildStatusBanner(market),
        ],
        const SizedBox(height: 18),
        _buildTabs(),
        const SizedBox(height: 20),
        LivePriceCard(
          assetLabel: '${_category.label} · ${headline.label}',
          price: formatPrice(headline.valueIn(rate)),
          unit: _category == MarketCategory.currency
              ? '${currency.code} per unit'
              : '${currency.code} / Gram',
          changePercent: formatPercentOrNull(headline.changePercent),
          isPositive: headline.isPositive,
          usdLabel: '~ \$${formatPrice(headline.usdValue)} USD',
          chartData: headline.trend,
          onViewDetails: _openAllPrices,
        ),
        const SizedBox(height: 28),
        Text(
          _category == MarketCategory.currency
              ? 'Other Rates'
              : 'Other ${_category == MarketCategory.gold ? 'Karats' : 'Purities'}',
          style: AppText.heading(21, color: context.c.textPrimary),
        ),
        const SizedBox(height: 14),
        _buildHorizontalList(items, currency.code, rate),
        const SizedBox(height: 26),
        _buildStatsGrid(snapshot, currency, rate),
        const SizedBox(height: 22),
        Center(
          child: Text(
            'Updated ${formatAgo(snapshot.updatedAt)} · prices are indicative',
            style: AppText.label(11, color: context.c.textMuted),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  void _openAllPrices() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllPricesScreen(category: _category),
      ),
    );
  }

  // ───────────────── Header ─────────────────
  Widget _buildHeader(AppCurrency currency) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.c.brass,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text('G', style: AppText.heading(22, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final name = state is AuthSuccess ? state.user.greetingName : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LIVE MARKET', style: AppText.micro(9.5, color: context.c.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    name.isEmpty ? 'Goldz' : 'Hi, $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading(19, color: context.c.textPrimary),
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
              color: context.c.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currency.code,
                    style: AppText.label(12,
                        color: context.c.textPrimary, weight: FontWeight.w700)),
                const SizedBox(width: 2),
                 Icon(Icons.keyboard_arrow_down_rounded,
                    size: 15, color: context.c.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
             Icon(Icons.notifications_none_rounded,
                size: 24, color: context.c.textPrimary),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.c.live,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.c.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────── Tabs ─────────────────
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.c.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: MarketCategory.values.map((category) {
          final selected = category == _category;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _category = category),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? context.c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ?  [
                          BoxShadow(
                            color: context.c.cardShadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  category.label,
                  textAlign: TextAlign.center,
                  style: AppText.label(
                    13.5,
                    color:
                        selected ? context.c.textPrimary : context.c.textSecondary,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalList(List<PriceItem> items, String code, double rate) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return KaratCard(
            badge: _category == MarketCategory.currency
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

  // ───────────────── Stats grid ─────────────────
  Widget _buildStatsGrid(
      MarketSnapshot snapshot, AppCurrency currency, double rate) {
    final stats = _buildStats(snapshot, currency, rate);
    if (stats.length < 4) return const SizedBox.shrink();

    return Column(
      children: [
        Row(children: [
          Expanded(child: _statCard(stats[0])),
          const SizedBox(width: 12),
          Expanded(child: _statCard(stats[1])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statCard(stats[2])),
          const SizedBox(width: 12),
          Expanded(child: _statCard(stats[3])),
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
      MarketSnapshot snap, AppCurrency currency, double rate) {
    final code = currency.code;

    switch (_category) {
      case MarketCategory.gold:
        final k24 = _find(snap.gold, '24');
        final k21 = _find(snap.gold, '21');
        if (k24 == null || k21 == null) return const [];
        return [
          _Stat('Global Ounce', '\$${formatBig(k24.usdValue * _gramsPerOunce)}',
              'USD'),
          _Stat('Local Ounce', formatBig(k24.usdValue * _gramsPerOunce * rate),
              code),
          // Egyptian gold pound = 8 grams of 21K
          _Stat('Gold Pound', formatBig(k21.usdValue * 8 * rate), code),
          _Stat('USD Rate', formatPrice(rate), code),
        ];

      case MarketCategory.silver:
        final s999 = _find(snap.silver, '999');
        final s925 = _find(snap.silver, '925');
        if (s999 == null || s925 == null) return const [];
        return [
          _Stat('Global Ounce',
              '\$${formatPrice(s999.usdValue * _gramsPerOunce)}', 'USD'),
          _Stat('Local Ounce', formatBig(s999.usdValue * _gramsPerOunce * rate),
              code),
          _Stat('Sterling 100g', formatBig(s925.usdValue * 100 * rate), code),
          _Stat('USD Rate', formatPrice(rate), code),
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
          _Stat('US Dollar', formatPrice(usd.valueIn(rate)), code),
          _Stat('Euro', formatPrice(eur.valueIn(rate)), code),
          _Stat('British Pound', formatPrice(gbp.valueIn(rate)), code),
          _Stat('Saudi Riyal', formatPrice(sar.valueIn(rate)), code),
        ];
    }
  }

  Widget _statCard(_Stat stat) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.label(12,
                  color: context.c.brass, weight: FontWeight.w600)),
          const SizedBox(height: 9),
          Text(stat.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.price(19, color: context.c.textPrimary)),
          const SizedBox(height: 3),
          Text(stat.currencyCode, style: AppText.label(11, color: context.c.textSecondary)),
        ],
      ),
    );
  }

  // ───────────────── Status / error ─────────────────
  Widget _buildStatusBanner(MarketState market) {
    final isError = market.error != null;
    final color = isError ? context.c.negative : context.c.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isError ? context.c.negativeSoft : context.c.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.cloud_off_rounded,
              size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              market.error ?? 'Showing saved prices — you may be offline',
              style: AppText.label(12, color: color),
            ),
          ),
          if (isError)
            GestureDetector(
              onTap: () => context.read<MarketCubit>().load(forceRefresh: true),
              child: Text('Retry',
                  style: AppText.label(12,
                      color: context.c.brass, weight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration:  BoxDecoration(
            color: context.c.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child:  Icon(Icons.wifi_off_rounded,
              size: 34, color: context.c.textMuted),
        ),
        const SizedBox(height: 20),
        Text('Could not load prices',
            textAlign: TextAlign.center, style: AppText.heading(20, color: context.c.textPrimary)),
        const SizedBox(height: 8),
        Text(
          error ??
              'Please check your internet connection. We need to be online to fetch the latest market data.',
          textAlign: TextAlign.center,
          style: AppText.label(13, color: context.c.textSecondary),
        ),
        const SizedBox(height: 22),
        Center(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.read<MarketCubit>().load(forceRefresh: true),
            icon:  Icon(Icons.refresh_rounded,
                size: 17, color: context.c.brass),
            label: Text('TRY AGAIN',
                style: AppText.micro(11.5, color: context.c.brass)),
            style: OutlinedButton.styleFrom(
              side:  BorderSide(color: context.c.brass),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────── Bottom nav ─────────────────
  Widget _buildBottomNav() {
    const items = [
      (Icons.trending_up_rounded, 'Market'),
      (Icons.list_alt_rounded, 'All Prices'),
      (Icons.calculate_outlined, 'Calculator'),
      (Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      decoration:  BoxDecoration(
        color: context.c.surface,
        border: Border(top: BorderSide(color: context.c.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == _navIndex;
          return GestureDetector(                 
            behavior: HitTestBehavior.opaque,
            onTap: () => _onNavTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? context.c.brass : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(items[i].$1,
                      size: 21,
                      color: selected ? Colors.white : context.c.textMuted),
                ),
                const SizedBox(height: 4),
                Text(items[i].$2,
                    style: AppText.label(10.5,
                        color: selected ? context.c.brass : context.c.textMuted,
                        weight: selected ? FontWeight.w600 : FontWeight.w500)),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _onNavTap(int i) {
    switch (i) {
      case 0:
        setState(() => _navIndex = 0);
      case 1:
        _openAllPrices();
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CalculatorScreen()),
        );
      case 3:
        _showAccountSheet();
    }
  }

  // ───────────────── Account sheet ─────────────────
  void _showAccountSheet() {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthSuccess ? state.user : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.c.brass,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          (user?.greetingName ?? 'G')
                              .characters
                              .first
                              .toUpperCase(),
                          style: AppText.heading(20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.greetingName ?? 'Guest',
                              style: AppText.heading(17, color: context.c.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            user == null || user.isGuest
                                ? 'Guest session'
                                : user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.label(12.5, color: context.c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _sheetRow(Icons.language_rounded, 'Language', 'English'),
              _sheetRow(Icons.contrast_rounded, 'Theme', 'Light'),
              _sheetRow(
                  Icons.notifications_active_outlined, 'Price alerts', ''),
              _sheetRow(Icons.star_outline_rounded, 'Rate the app', ''),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.read<AuthBloc>().add(const SignOutRequested());
                    },
                    icon:  Icon(Icons.logout_rounded,
                        size: 17, color: context.c.negative),
                    label: Text('SIGN OUT',
                        style: AppText.micro(11.5, color: context.c.negative)),
                    style: OutlinedButton.styleFrom(
                      side:  BorderSide(color: context.c.negative),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetRow(IconData icon, String title, String trailing) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 19, color: context.c.textPrimary ),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(title,
                      style: AppText.label(14, color: context.c.textPrimary))),
              if (trailing.isNotEmpty) Text(trailing, style: AppText.label(13, color: context.c.textMuted)),
              const SizedBox(width: 6),
               Icon(Icons.chevron_right_rounded,
                  size: 18, color: context.c.textMuted),
            ],
          ),
        ),
         Divider(height: 1, color: context.c.divider, indent: 20),
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
