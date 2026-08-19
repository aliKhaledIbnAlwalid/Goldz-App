import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
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

  double get _weightInGrams => _inGrams ? _weight : _weight * _gramsPerOunce;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text(context.l10n.appName, style: AppText.micro(15, color: c.brass)),
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
                      : Text(context.l10n.pricesUnavailable,
                          style:
                              AppText.label(14, color: c.textSecondary)),
                );
              }

              final rate = snapshot.rateFor(currency.code, currency.perUsd);

              PriceItem? karat;
              for (final item in snapshot.gold) {
                if (item.id == _karatId) karat = item;
              }

              if (karat == null) {
                return Center(
                  child: Text(context.l10n.pricesUnavailable,
                      style: AppText.label(14, color: c.textSecondary)),
                );
              }

              final pricePerGram = karat.valueIn(rate);
              final total = pricePerGram * _weightInGrams;
              final purity =
                  (int.parse(_karatId) / 24 * 100).toStringAsFixed(1);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(context.l10n.valuationCalculator,
                      style: AppText.heading(24, color: c.textPrimary)),
                  const SizedBox(height: 6),
                  Text(context.l10n.valuationSubtitle,
                      style: AppText.label(13.5, color: c.textSecondary)),
                  const SizedBox(height: 26),

                  Text(context.l10n.weight,
                      style: AppText.micro(10, color: c.textMuted)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          // Numbers stay LTR even in Arabic.
                          textDirection: TextDirection.ltr,
                          onChanged: (_) => setState(() {}),
                          style: AppText.price(24, color: c.textPrimary),
                          decoration: InputDecoration(
                            hintText: '0.0',
                            filled: false,
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: c.border)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: c.brass)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _unitToggle(),
                    ],
                  ),
                  const SizedBox(height: 26),

                  Text(context.l10n.purityKarat,
                      style: AppText.micro(10, color: c.textMuted)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _karatOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final id = _karatOptions[i];
                        final selected = id == _karatId;
                        return GestureDetector(
                          onTap: () => setState(() => _karatId = id),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? c.brass : c.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: selected ? c.brass : c.border),
                            ),
                            child: Text(
                              '$id K',
                              style: AppText.label(13,
                                  color: selected
                                      ? c.onBrass
                                      : c.textSecondary,
                                  weight: FontWeight.w600),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.border),
                    ),
                    child: Column(
                      children: [
                        Text(context.l10n.estimatedValue,
                            style: AppText.micro(10, color: c.textMuted)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                formatPrice(total),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.price(34, color: c.brass),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(currency.code,
                                  style: AppText.label(15,
                                      color: c.brass,
                                      weight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(height: 1, color: c.divider),
                        _breakdownRow(context.l10n.pricePerGram,
                            '${formatPrice(pricePerGram)} ${currency.code}'),
                        Divider(height: 1, color: c.divider),
                        _breakdownRow(context.l10n.weight,
                            '${formatPrice(_weightInGrams)} g'),
                        Divider(height: 1, color: c.divider),
                        _breakdownRow(
                            context.l10n.purity,
                            context.l10n
                                .karatWithPercent(_karatId, purity)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  Text(context.l10n.calculatorDisclaimer,
                      textAlign: TextAlign.center,
                      style: AppText.label(11.5, color: c.brass)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _unitToggle() {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitOption('g', _inGrams),
          _unitOption('oz', !_inGrams),
        ],
      ),
    );
  }

  Widget _unitOption(String label, bool selected) {
    final c = context.c;
    return GestureDetector(
      onTap: () => setState(() => _inGrams = label == 'g'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: AppText.label(12.5,
              color: selected ? c.textPrimary : c.textMuted,
              weight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, String value) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label, style: AppText.label(13, color: c.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppText.price(15, color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}