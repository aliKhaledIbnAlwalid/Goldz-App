import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'sparkline.dart';

class KaratCard extends StatelessWidget {
  final String karat;
  final String title; // 🆕 e.g. 'Karat 21' / 'Sterling 925' / 'Euro'
  final String change;
  final String priceEgp;
  final String priceUsd;
  final bool isPositive;
  final List<double> chartData;

  const KaratCard({
    super.key,
    required this.karat,
    required this.title, // 🆕
    required this.change,
    required this.priceEgp,
    required this.priceUsd,
    this.isPositive = true,
    this.chartData = const [2, 2.3, 2.1, 2.6, 2.4, 2.9, 3.1],
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive ? AppColors.positive : AppColors.negative;

    return Container(
      width: 152,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(
                    colors: [AppColors.goldSoft, AppColors.goldDark],
                  ),
                ),
                child: Center(
                  child: Text(
                    karat,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3B2A08),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            priceEgp,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            priceUsd,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: Sparkline(data: chartData, color: trendColor),
          ),
        ],
      ),
    );
  }
}
