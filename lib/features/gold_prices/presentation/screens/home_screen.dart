import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
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
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<CurrencyCubit, AppCurrency>(
            builder: (context, currency) {
              return BlocBuilder<MarketCubit, MarketState>(
                builder: (context, market) {
                  return RefreshIndicator(
                    color: AppColors.gold,
                    backgroundColor: AppColors.card,
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

    // First load, nothing cached yet.
    if (snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 10),
          _buildHeader(currency),
          const SizedBox(height: 80),
          if (market.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          else
            _buildErrorState(market.error),
        ],
      );
    }

    // Live conversion rate, falling back to the built-in value.
    final rate = snapshot.rateFor(currency.code, currency.perUsd);

    final items = snapshot.of(_category);
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 10),
          _buildHeader(currency),
          const SizedBox(height: 60),
          Center(
            child: Text(
              'No ${_category.label.toLowerCase()} data available right now.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }

    final headline = snapshot.headline(_category);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 10),
        _buildHeader(currency),
        if (market.isStale || market.error != null) ...[
          const SizedBox(height: 12),
          _buildStatusBanner(market),
        ],
        const SizedBox(height: 20),
        _buildTabs(),
        const SizedBox(height: 20),

        LivePriceCard(
          title: '${_category.label} · ${headline.label}',
          price: formatPrice(headline.valueIn(rate)),
          unit: '${currency.code} ${headline.unit}'.trim(),
          changePercent: formatPercentOrNull(headline.changePercent),
          isPositive: headline.isPositive,
          usdPerGram:
              '\$${formatPrice(headline.usdValue)} ${headline.unit}'.trim(),
          usdPerOunce: _category == MarketCategory.currency
              ? 'per unit'
              : '\$${formatPrice(headline.usdValue * _gramsPerOunce)} / oz',
          chartData: headline.trend,
        ),
        const SizedBox(height: 26),

        _buildSectionHeader(
          _category.sectionTitle,
          'See all',
          onAction: _openAllPrices,
        ),
        const SizedBox(height: 12),
        _buildHorizontalList(items, currency, rate),
        const SizedBox(height: 26),

        _buildSectionHeader(
          _category == MarketCategory.currency ? 'MARKET' : 'OUNCE',
          '',
        ),
        const SizedBox(height: 12),
        _buildStatsGrid(snapshot, currency, rate),
        const SizedBox(height: 20),
        _buildUpdatedFooter(snapshot),
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

  // ───────────────────── Status banner ─────────────────────
  Widget _buildStatusBanner(MarketState market) {
    final isError = market.error != null;
    final color = isError ? AppColors.negative : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.6),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.cloud_off_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              market.error ?? 'Showing saved prices — you may be offline.',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
          if (isError)
            GestureDetector(
              onTap: () =>
                  context.read<MarketCubit>().load(forceRefresh: true),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Column(
      children: [
        const Icon(Icons.wifi_off_rounded,
            size: 42, color: AppColors.textMuted),
        const SizedBox(height: 14),
        Text(
          error ?? 'Could not load prices.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Center(
          child: OutlinedButton(
            onPressed: () =>
                context.read<MarketCubit>().load(forceRefresh: true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.divider),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Try again',
                style: TextStyle(color: AppColors.gold)),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Header ─────────────────────────
  Widget _buildHeader(AppCurrency currency) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [AppColors.goldSoft, AppColors.goldDark],
            ),
          ),
          child: const Center(
            child: Text('G',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3B2A08),
                )),
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
                  Text(
                    name.isEmpty ? 'Goldz' : 'Hi, $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'LIVE MARKET',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _circleIcon(Icons.notifications_none_rounded, () {}),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => showCurrencySheet(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currency.flag, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  currency.code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.chipBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  // ───────────────────────── Tabs ─────────────────────────
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: MarketCategory.values.map((category) {
          final selected = category == _category;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _category = category),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: selected
                      ? const LinearGradient(
                          colors: [AppColors.goldSoft, AppColors.gold])
                      : null,
                ),
                child: Text(
                  category.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF3B2A08)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action,
      {VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(action,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    )),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.gold),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalList(
    List<PriceItem> items,
    AppCurrency currency,
    double rate,
  ) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return KaratCard(
            karat: item.badge,
            title: item.label,
            change: formatPercentOrNull(item.changePercent),
            priceEgp: formatPrice(item.valueIn(rate)),
            priceUsd: '\$${formatPrice(item.usdValue)}',
            isPositive: item.isPositive,
            chartData: item.trend,
          );
        },
      ),
    );
  }

  // ───────────────── Stats grid ─────────────────
  Widget _buildStatsGrid(
    MarketSnapshot snapshot,
    AppCurrency currency,
    double rate,
  ) {
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
    MarketSnapshot snap,
    AppCurrency currency,
    double rate,
  ) {
    final code = currency.code;

    switch (_category) {
      case MarketCategory.gold:
        final k24 = _find(snap.gold, '24');
        final k21 = _find(snap.gold, '21');
        if (k24 == null || k21 == null) return const [];
        return [
          _Stat('Gold Ounce',
              formatBig(k24.usdValue * _gramsPerOunce * rate), code),
          _Stat('Local Ounce · 24K',
              formatBig(k24.usdValue * _gramsPerOunce * rate * 1.004), code),
          // The Egyptian gold pound is 8 grams of 21K.
          _Stat('Gold Pound · 21K',
              formatBig(k21.usdValue * 8 * rate), code),
          _Stat('Dollar Rate', formatPrice(rate), code),
        ];

      case MarketCategory.silver:
        final s999 = _find(snap.silver, '999');
        final s925 = _find(snap.silver, '925');
        if (s999 == null || s925 == null) return const [];
        return [
          _Stat('Silver Ounce',
              formatBig(s999.usdValue * _gramsPerOunce * rate), code),
          _Stat('Local Ounce · 999',
              formatBig(s999.usdValue * _gramsPerOunce * rate * 1.004), code),
          _Stat('Sterling · 100g',
              formatBig(s925.usdValue * 100 * rate), code),
          _Stat('Dollar Rate', formatPrice(rate), code),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Text(stat.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text(stat.currencyCode,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildUpdatedFooter(MarketSnapshot snapshot) {
    return Center(
      child: Text(
        'Updated ${formatAgo(snapshot.updatedAt)} · prices are indicative',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textMuted.withOpacity(0.9),
        ),
      ),
    );
  }

  // ─────────────────────── Bottom nav ───────────────────────
  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.calculate_outlined, 'Calculator'),
      (Icons.show_chart_rounded, 'Charts'),
      (Icons.notifications_none_rounded, 'Alerts'),
      (Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 22),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border:
            Border(top: BorderSide(color: AppColors.divider, width: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == _navIndex;
          final color = selected ? AppColors.gold : AppColors.textMuted;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (i == 4) {
                _showAccountSheet();
              } else {
                setState(() => _navIndex = i);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(items[i].$1, size: 23, color: color),
                  const SizedBox(height: 4),
                  Text(items[i].$2,
                      style: TextStyle(fontSize: 10, color: color)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showAccountSheet() {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthSuccess ? state.user : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColors.goldSoft, AppColors.goldDark],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (user?.greetingName ?? 'G')
                            .characters
                            .first
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
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
                        Text(user?.greetingName ?? 'Guest',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          user == null || user.isGuest
                              ? 'Guest session'
                              : user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (user?.isGuest ?? false) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).pushNamed('/register');
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined,
                      size: 19, color: AppColors.gold),
                  label: const Text('Create an account',
                      style: TextStyle(color: AppColors.gold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.read<AuthBloc>().add(const SignOutRequested());
                },
                icon: const Icon(Icons.logout_rounded,
                    size: 19, color: AppColors.negative),
                label: const Text('Sign out',
                    style: TextStyle(color: AppColors.negative)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat {
  final String title;
  final String value;
  final String currencyCode;

  const _Stat(this.title, this.value, this.currencyCode);
}