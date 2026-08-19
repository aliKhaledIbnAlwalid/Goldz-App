import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
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
    final c = context.c;
    final trendColor = change == null
        ? c.textMuted
        : (isPositive ? c.positive : c.negative);

    return Container(
      width: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(badge,
                    style: AppText.label(11.5,
                        color: c.textPrimary, weight: FontWeight.w700)),
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
                Text('—', style: AppText.label(11, color: c.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          Text(price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.price(24, color: c.textPrimary)),
          const SizedBox(height: 3),
          Text(currencyCode,
              style: AppText.label(11.5, color: c.textMuted)),
          const SizedBox(height: 10),
          // Absorbs leftover height — no more overflow on font scaling.
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