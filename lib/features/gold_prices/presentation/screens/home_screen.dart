import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/dummy_market_data.dart';
import '../../domain/entities/price_item.dart';
import '../widgets/currency_sheet.dart';
import '../widgets/karat_card.dart';
import '../widgets/live_price_card.dart';
import 'all_prices_screen.dart';

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
              final items = DummyMarketData.of(_category);
              final headline = DummyMarketData.headline(_category);

              return RefreshIndicator(
                color: AppColors.gold,
                backgroundColor: AppColors.card,
                onRefresh: () async =>
                    Future.delayed(const Duration(milliseconds: 800)),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(currency),
                    const SizedBox(height: 20),
                    _buildTabs(),
                    const SizedBox(height: 20),

                    // ── Hero card ──
                    LivePriceCard(
                      title: '${_category.label} · ${headline.label}',
                      price: formatPrice(headline.valueIn(currency.perUsd)),
                      unit: '${currency.code} ${headline.unit}'.trim(),
                      changePercent:
                          formatPercent(headline.changePercent).substring(1),
                      isPositive: headline.isPositive,
                      usdPerGram:
                          '\$${formatPrice(headline.usdValue)} ${headline.unit}'
                              .trim(),
                      usdPerOunce: _category == MarketCategory.currency
                          ? 'per unit'
                          : '\$${formatPrice(headline.usdValue * DummyMarketData.gramsPerOunce)} / oz',
                      chartData: headline.trend,
                    ),
                    const SizedBox(height: 26),

                    // ── Horizontal list + See all ──
                    _buildSectionHeader(
                      _category.sectionTitle,
                      'See all',
                      onAction: _openAllPrices,
                    ),
                    const SizedBox(height: 12),
                    _buildHorizontalList(items, currency),
                    const SizedBox(height: 26),

                    // ── Stats grid ──
                    _buildSectionHeader(
                      _category == MarketCategory.currency
                          ? 'MARKET'
                          : 'OUNCE',
                      '',
                    ),
                    const SizedBox(height: 12),
                    _buildStatsGrid(currency),
                    const SizedBox(height: 20),
                    _buildUpdatedFooter(),
                    const SizedBox(height: 28),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  void _openAllPrices() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllPricesScreen(category: _category),
      ),
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
            child: Text(
              'G',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3B2A08),
              ),
            ),
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

        // ── Currency selector (tappable) ──
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

  // ───────────────────── Section header ─────────────────────
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
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.gold),
              ],
            ),
          ),
      ],
    );
  }

  // ─────────────────── Horizontal list ───────────────────
  Widget _buildHorizontalList(List<PriceItem> items, AppCurrency currency) {
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
            change: formatPercent(item.changePercent),
            priceEgp: formatPrice(item.valueIn(currency.perUsd)),
            priceUsd: '\$${formatPrice(item.usdValue)}',
            isPositive: item.isPositive,
            chartData: item.trend,
          );
        },
      ),
    );
  }

  // ───────────────────── Stats grid (4 cards) ─────────────────────
  Widget _buildStatsGrid(AppCurrency currency) {
    final stats = _buildStats(currency);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard(stats[0])),
            const SizedBox(width: 12),
            Expanded(child: _statCard(stats[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statCard(stats[2])),
            const SizedBox(width: 12),
            Expanded(child: _statCard(stats[3])),
          ],
        ),
      ],
    );
  }

  List<_Stat> _buildStats(AppCurrency currency) {
    final rate = currency.perUsd;
    final oz = DummyMarketData.gramsPerOunce;
    final usd = DummyMarketData.currency.firstWhere((e) => e.id == 'USD');

    switch (_category) {
      case MarketCategory.gold:
        final k24 = DummyMarketData.gold.firstWhere((e) => e.id == '24');
        final k21 = DummyMarketData.gold.firstWhere((e) => e.id == '21');
        return [
          _Stat('Gold Ounce', formatBig(k24.usdValue * oz * rate),
              currency.code, '+0.9%'),
          _Stat('Local Ounce · 24K',
              formatBig(k24.usdValue * oz * rate * 1.004),
              currency.code, '+0.9%'),
          _Stat('Gold Pound · 21K', formatBig(k21.usdValue * 8 * rate),
              currency.code, '+0.8%'),
          _Stat('Dollar Rate', formatPrice(usd.usdValue * rate),
              currency.code, '+0.1%'),
        ];

      case MarketCategory.silver:
        final s999 = DummyMarketData.silver.firstWhere((e) => e.id == '999');
        final s925 = DummyMarketData.silver.firstWhere((e) => e.id == '925');
        return [
          _Stat('Silver Ounce', formatBig(s999.usdValue * oz * rate),
              currency.code, '+0.5%'),
          _Stat('Local Ounce · 999',
              formatBig(s999.usdValue * oz * rate * 1.004),
              currency.code, '+0.5%'),
          _Stat('Sterling · 100g', formatBig(s925.usdValue * 100 * rate),
              currency.code, '+0.4%'),
          _Stat('Dollar Rate', formatPrice(usd.usdValue * rate),
              currency.code, '+0.1%'),
        ];

      case MarketCategory.currency:
        final eur = DummyMarketData.currency.firstWhere((e) => e.id == 'EUR');
        final gbp = DummyMarketData.currency.firstWhere((e) => e.id == 'GBP');
        final sar = DummyMarketData.currency.firstWhere((e) => e.id == 'SAR');
        return [
          _Stat('US Dollar', formatPrice(usd.usdValue * rate),
              currency.code, '+0.1%'),
          _Stat('Euro', formatPrice(eur.usdValue * rate),
              currency.code, '+0.2%'),
          _Stat('British Pound', formatPrice(gbp.usdValue * rate),
              currency.code, '+0.2%'),
          _Stat('Saudi Riyal', formatPrice(sar.usdValue * rate),
              currency.code, '+0.0%'),
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
          Text(
            stat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                stat.currencyCode,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                stat.change,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.positive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatedFooter() {
    return Center(
      child: Text(
        'Last updated just now · prices are indicative',
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

  // ──────────────────── Account sheet ────────────────────
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
                        Text(
                          user?.greetingName ?? 'Guest',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
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

/// Small value object for the 4 stat cards.
class _Stat {
  final String title;
  final String value;
  final String currencyCode;
  final String change;

  const _Stat(this.title, this.value, this.currencyCode, this.change);
}