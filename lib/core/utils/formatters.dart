import 'package:intl/intl.dart';

final _priceFormat = NumberFormat('#,##0.00', 'en');
final _bigFormat = NumberFormat('#,##0', 'en');

String formatPrice(double value) => _priceFormat.format(value);
String formatBig(double value) => _bigFormat.format(value);

String formatPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}%';
}

/// Null means "we have no change figure" — never fake a zero.
String? formatPercentOrNull(double? value) =>
    value == null ? null : formatPercent(value);

String formatAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}