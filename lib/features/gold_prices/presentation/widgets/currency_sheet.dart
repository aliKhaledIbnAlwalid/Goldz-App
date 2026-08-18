import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldz/core/theme/app_palette.dart';
import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';

Future<void> showCurrencySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.c.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: context.c.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Display currency',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.c.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Prices will be converted instantly',
              style: TextStyle(fontSize: 12.5, color: context.c.textSecondary),
            ),
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
                      color: context.c.positiveSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? context.c.brass
                            : context.c.divider,
                        width: isSelected ? 1.2 : 0.6,
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
                              Text(
                                currency.code,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: context.c.textPrimary,
                                ),
                              ),
                              Text(
                                currency.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:  context.c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: context.c.brass, size: 22),
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