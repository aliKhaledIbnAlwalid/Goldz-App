import 'package:equatable/equatable.dart';

class AppCurrency extends Equatable {
  final String code;    // EGP
  final String name;    // Egyptian Pound
  final String flag;    // 🇪🇬
  final double perUsd;  // how much of this currency = 1 USD

  const AppCurrency({
    required this.code,
    required this.name,
    required this.flag,
    required this.perUsd,
  });

  @override
  List<Object?> get props => [code, name, flag, perUsd];
}

class AppCurrencies {
  AppCurrencies._();

  static const egp = AppCurrency(
    code: 'EGP',
    name: 'Egyptian Pound',
    flag: '🇪🇬',
    perUsd: 49.20,
  );

  static const sar = AppCurrency(
    code: 'SAR',
    name: 'Saudi Riyal',
    flag: '🇸🇦',
    perUsd: 3.75,
  );

  /// Add more here later — the whole UI adapts automatically.
  static const supported = <AppCurrency>[egp, sar];
}