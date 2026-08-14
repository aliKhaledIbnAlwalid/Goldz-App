class ApiConstants {
  ApiConstants._();

  // GoldAPI.io — metals
  static const goldApiBase = 'https://www.goldapi.io/api';
  static const symbolGold = 'XAU';
  static const symbolSilver = 'XAG';

  // ExchangeRate-API open endpoint (no key, attribution required)
  static const fxBase = 'https://open.er-api.com/v6/latest';

  /// Everything is fetched in USD, then converted locally.
  static const baseCurrency = 'USD';

  /// How long cached data stays "fresh" before we refetch.
  static const metalsTtl = Duration(minutes: 15);
  static const fxTtl = Duration(hours: 12);

  static const gramsPerTroyOunce = 31.1035;
}