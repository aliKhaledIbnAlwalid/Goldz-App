import 'package:flutter/material.dart';
import 'package:goldz/core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import 'sparkline.dart';

class KaratCard extends StatelessWidget {
  final String badge;
  final String price;
  final String currencyCode;
  final String? change;
  final bool isPositive;
  final List<double> chartData;

  const KaratCard({
    super.key,
    required this.badge,
    required this.price,
    required this.currencyCode,
    required this.change,
    required this.isPositive,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = change == null
        ? context.c.textMuted
        : (isPositive ? context.c.positive : context.c.negative);

    return Container(
      width: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: context.c.surfaceAlt,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(badge,
                    style: AppText.label(11.5,
                        color: context.c.textMuted,
                        weight: FontWeight.w700)),
              ),
              const Spacer(),
              if (change != null)
                Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(change!,
                        style: AppText.label(11,
                            color: trendColor, weight: FontWeight.w600)),
                  ],
                )
              else
                Text('—', style: AppText.label(11, color: context.c.brass)),
            ],
          ),
          const SizedBox(height: 14),
          Text(price, style: AppText.price(24, color: context.c.textMuted)),
          const SizedBox(height: 3),
          Text(currencyCode,
              style: AppText.label(11.5, color: context.c.textMuted)),
                    const SizedBox(height: 10),
          // Expanded absorbs leftover height instead of overflowing.
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Sparkline(data: chartData, color: trendColor),
            ),
          ),
        ],
      ),
    );
  }
}