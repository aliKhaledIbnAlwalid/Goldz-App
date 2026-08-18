import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/core/theme/app_palette.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/formatters.dart';
import '../../../gold_prices/domain/entities/price_item.dart';
import '../../../gold_prices/presentation/cubit/market_cubit.dart';
import '../../../gold_prices/presentation/cubit/market_state.dart';

const _gramsPerOunce = 31.1035;

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _weightController = TextEditingController(text: '12.5');
  bool _inGrams = true;
  String _karatId = '21';

  static const _karatOptions = ['24', '22', '21', '18', '14'];

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  double get _weight => double.tryParse(_weightController.text) ?? 0;

  double get _weightInGrams =>
      _inGrams ? _weight : _weight * _gramsPerOunce;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.background,
      appBar: AppBar(
        title: Text('GOLDZ', style: AppText.micro(15, color: context.c.brass)),
      ),
      body: BlocBuilder<CurrencyCubit, AppCurrency>(
        builder: (context, currency) {
          return BlocBuilder<MarketCubit, MarketState>(
            builder: (context, market) {
              final snapshot = market.snapshot;

              if (snapshot == null) {
                return Center(
                  child: market.isLoading
                      ?  CircularProgressIndicator(
                          color: context.c.brass)
                      : Text('Prices unavailable — try again later.',
                          style: AppText.label(14, color: context.c.textMuted)),
                );
              }

              final rate =
                  snapshot.rateFor(currency.code, currency.perUsd);

              PriceItem? karat;
              for (final item in snapshot.gold) {
                if (item.id == _karatId) karat = item;
              }
              if (karat == null) {
                return Center(
                    child: Text('Karat data unavailable.',
                        style: AppText.label(14, color: context.c.textMuted)));
              }

              final pricePerGram = karat.valueIn(rate);
              final total = pricePerGram * _weightInGrams;
              final purity =
                  (int.parse(_karatId) / 24 * 100).toStringAsFixed(1);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text('Valuation Calculator', style: AppText.heading(24, color: context.c.brass)),
                  const SizedBox(height: 6),
                  Text("Estimate your asset's current market worth.",
                      style: AppText.label(13.5, color: context.c.textMuted)),
                  const SizedBox(height: 26),

                  Text('WEIGHT', style: AppText.micro(10, color: context.c.brass)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) => setState(() {}),
                          style: AppText.price(24,
                              color: context.c.textMuted),
                          decoration: InputDecoration(
                            hintText: '0.0',
                            filled: false,
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: context.c.border),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: context.c.brass),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _unitToggle(),
                    ],
                  ),
                  const SizedBox(height: 26),

                  Text('PURITY (KARAT)', style: AppText.micro(10, color: context.c.brass)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _karatOptions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final id = _karatOptions[i];
                        final selected = id == _karatId;
                        return GestureDetector(
                          onTap: () => setState(() => _karatId = id),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? context.c.brass
                                  : context.c.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selected
                                    ? context.c.brass
                                    : context.c.border,
                              ),
                            ),
                            child: Text('$id K',
                                style: AppText.label(13,
                                    color: selected
                                        ? Colors.white
                                        : context.c.textSecondary,
                                    weight: FontWeight.w600)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.c.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.c.border),
                    ),
                    child: Column(
                      children: [
                        Text('ESTIMATED VALUE',
                            style: AppText.micro(10, color: context.c.brass)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(formatPrice(total),
                                style: AppText.price(34, color: context.c.brass)),
                            const SizedBox(width: 7),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(currency.code,
                                  style: AppText.label(15,
                                      color: context.c.brass,
                                      weight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                         Divider(
                            height: 1, color: context.c.divider),
                        _breakdownRow('Price per gram',
                            '${formatPrice(pricePerGram)} ${currency.code}'),
                         Divider(
                            height: 1, color: context.c.divider),
                        _breakdownRow('Weight',
                            '${formatPrice(_weightInGrams)} g'),
                        Divider(
                            height: 1, color: context.c.divider),
                        _breakdownRow(
                            'Purity', '$_karatId Karat · $purity%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Values are estimates based on live market spot prices. '
                    'Actual transactional values may vary depending on local '
                    'dealer premiums, manufacturing fees, and physical condition.',
                    textAlign: TextAlign.center,
                    style: AppText.label(11.5, color: context.c.brass),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _unitToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.c.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _unitOption('g', _inGrams),
          _unitOption('oz', !_inGrams),
        ],
      ),
    );
  }

  Widget _unitOption(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _inGrams = label == 'g'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.c.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label,
            style: AppText.label(12.5,
                color: selected
                    ? context.c.brass
                    : context.c.textMuted,
                weight: FontWeight.w600)),
      ),
    );
  }

  Widget _breakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label, style: AppText.label(13, color: context.c.brass)),
          const Spacer(),
          Text(value,
              style: AppText.price(15, color: context.c.textMuted)),
        ],
      ),
    );
  }
}