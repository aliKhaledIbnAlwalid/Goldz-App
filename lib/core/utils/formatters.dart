import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'context_ext.dart';

// Always 'en' — Egyptian price apps use Latin digits, not Arabic-Indic.
final _priceFormat = NumberFormat('#,##0.00', 'en');
final _bigFormat = NumberFormat('#,##0', 'en');

String formatPrice(double value) => _priceFormat.format(value);
String formatBig(double value) => _bigFormat.format(value);

String formatPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}%';
}

String? formatPercentOrNull(double? value) =>
    value == null ? null : formatPercent(value);

String formatAgo(BuildContext context, DateTime time) {
  final l = context.l10n;
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return l.justNow;
  if (diff.inMinutes < 60) return l.minutesAgo('${diff.inMinutes}');
  if (diff.inHours < 24) return l.hoursAgo('${diff.inHours}');
  return l.daysAgo('${diff.inDays}');
}