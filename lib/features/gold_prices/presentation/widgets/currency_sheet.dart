import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';

Future<void> showCurrencySheet(BuildContext context) {
  final c = context.c;
  return showModalBottomSheet(
    context: context,
    backgroundColor: c.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      final selected = context.read<CurrencyCubit>().state;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.displayCurrency,
                style: AppText.heading(18, color: c.textPrimary)),
            const SizedBox(height: 4),
            Text(context.l10n.currencySubtitle,
                style: AppText.label(12.5, color: c.textSecondary)),
            const SizedBox(height: 18),
            ...AppCurrencies.supported.map((currency) {
              final isSelected = currency.code == selected.code;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.read<CurrencyCubit>().select(currency);
                    Navigator.pop(sheetContext);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? c.brass : c.border,
                        width: isSelected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(currency.flag,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currency.code,
                                  style: AppText.label(15,
                                      color: c.textPrimary,
                                      weight: FontWeight.w700)),
                              Text(currency.name,
                                  style: AppText.label(12,
                                      color: c.textSecondary)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: c.brass, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}