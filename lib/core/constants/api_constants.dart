class ApiConstants {
  ApiConstants._();

  // Primary metals
  static const goldUrl = 'https://api.gold-api.com/price/XAU';
  static const silverUrl = 'https://api.gold-api.com/price/XAG';

  // Backup metals — keyless anonymous tier
  static const goldFallbackUrl =
      'https://api.goldprice.dev/v1/prices?symbol=XAU-USD-SPOT';
  static const silverFallbackUrl =
      'https://api.goldprice.dev/v1/prices?symbol=XAG-USD-SPOT';

  // FX
  static const fxUrl = 'https://open.er-api.com/v6/latest/USD';
  static const fxFallbackUrl = 'https://api.exchangerate.fun/latest?base=USD';

  static const priceTtl = Duration(minutes: 10);
  static const fxTtl = Duration(hours: 24);
  static const rateLimitCooldown = Duration(minutes: 15);

  static const historyInterval = Duration(minutes: 10);
  static const historyMaxPoints = 200;

  static const gramsPerTroyOunce = 31.1035;
}