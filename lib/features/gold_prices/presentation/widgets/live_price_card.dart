import 'package:flutter/material.dart';
import 'package:goldz/core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import 'sparkline.dart';

class LivePriceCard extends StatelessWidget {
  final String assetLabel;
  final String price;
  final String unit;
  final String? changePercent;
  final bool isPositive;
  final String usdLabel;
  final List<double> chartData;
  final VoidCallback? onViewDetails;

  const LivePriceCard({
    super.key,
    required this.assetLabel,
    required this.price,
    required this.unit,
    required this.changePercent,
    required this.isPositive,
    required this.usdLabel,
    required this.chartData,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive ? context.c.positive : context.c.negative;

    return Container(
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.c.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.c.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: context.c.live,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text('LIVE',
                        style: AppText.micro(10, color: context.c.live)),
                    const Spacer(),
                    if (changePercent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? context.c.positiveSoft
                              : context.c.negativeSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 13,
                              color: trendColor,
                            ),
                            const SizedBox(width: 5),
                            Text(changePercent!,
                                style: AppText.label(11.5,
                                    color: trendColor,
                                    weight: FontWeight.w700)),
                          ],
                        ),
                      )
                    else
                      Text('no change data yet',
                          style: AppText.label(11,
                              color: context.c.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(assetLabel,
                    style: AppText.label(14.5,
                        color: context.c.brass, weight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(price, style: AppText.price(40, color: context.c.brass)),
                const SizedBox(height: 6),
                Text(unit,
                    style: AppText.label(13, color: context.c.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            height: 92,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
              child: Sparkline(
                data: chartData,
                color: context.c.brassLight,
                showEndDot: true,
              ),
            ),
          ),
          Divider(height: 1, color: context.c.divider),
          InkWell(
            onTap: onViewDetails,
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Text(usdLabel,
                      style: AppText.label(12.5,
                          color: context.c.textSecondary)),
                  const Spacer(),
                  Text('VIEW DETAILS',
                      style: AppText.micro(11, color:context.c.brass)),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: context.c.brass),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}