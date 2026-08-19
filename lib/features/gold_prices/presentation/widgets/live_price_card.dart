import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/context_ext.dart';
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
    final c = context.c;
    final l = context.l10n;
    final trendColor = isPositive ? c.positive : c.negative;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border, width: 1),
        boxShadow: [
          BoxShadow(color: c.cardShadow, blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: c.live, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 7),
                    Text(l.live, style: AppText.micro(10, color: c.live)),
                    const Spacer(),
                    if (changePercent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPositive ? c.positiveSoft : c.negativeSoft,
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
                      Text(l.noChangeData,
                          style: AppText.label(11, color: c.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(assetLabel,
                    style: AppText.label(14.5,
                        color: c.brass, weight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(price, style: AppText.price(40, color: c.brass)),
                const SizedBox(height: 6),
                Text(unit,
                    style: AppText.label(13, color: c.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            height: 92,
            width: double.infinity,
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
              child: Sparkline(
                data: chartData,
                color: c.brassLight,
                showEndDot: true,
                dotRingColor: c.surface,
              ),
            ),
          ),
          Divider(height: 1, color: c.divider),
          InkWell(
            onTap: onViewDetails,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Text(usdLabel,
                      style: AppText.label(12.5, color: c.textSecondary)),
                  const Spacer(),
                  Text(l.viewDetails,
                      style: AppText.micro(11, color: c.brass)),
                  Icon(
                    context.isRtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 18,
                    color: c.brass,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}