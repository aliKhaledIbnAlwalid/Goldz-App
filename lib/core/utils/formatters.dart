import 'package:intl/intl.dart';

final _priceFormat = NumberFormat('#,##0.00', 'en');
final _bigFormat = NumberFormat('#,##0', 'en');

String formatPrice(double value) => _priceFormat.format(value);
String formatBig(double value) => _bigFormat.format(value);

String formatPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}%';
}