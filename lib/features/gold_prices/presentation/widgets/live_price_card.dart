import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'sparkline.dart';

class LivePriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String unit;
  final String changePercent;
  final bool isPositive;
  final String usdPerGram;
  final String usdPerOunce;
  final List<double> chartData;

  const LivePriceCard({
    super.key,
    required this.title,
    required this.price,
    required this.unit,
    required this.changePercent,
    required this.isPositive,
    required this.usdPerGram,
    required this.usdPerOunce,
    this.chartData = const [3, 3.4, 3.2, 3.9, 3.6, 4.2, 3.9, 4.6, 4.3, 4.9, 5.2],
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive ? AppColors.positive : AppColors.negative;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardLight, AppColors.card],
        ),
        border: Border.all(color: AppColors.divider, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + LIVE badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.positive.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    _PulseDot(),
                    SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.positive,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Big price ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Change chip ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '${isPositive ? '▲' : '▼'} $changePercent',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: trendColor,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Chart ──
          SizedBox(
            height: 72,
            width: double.infinity,
            child: Sparkline(data: chartData),
          ),
          const SizedBox(height: 16),

          // ── Footer ──
          Row(
            children: [
              Text(
                usdPerGram,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Container(width: 1, height: 14, color: AppColors.divider),
              const SizedBox(width: 14),
              Text(
                usdPerOunce,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small breathing dot for the LIVE badge.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_c),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.positive,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}