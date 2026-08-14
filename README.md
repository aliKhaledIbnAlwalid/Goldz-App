# Goldz — أسعار الذهب في مصر

Live gold, silver and currency prices for the Egyptian market, built with Flutter.

## Features
- Live gold prices by karat (24K–9K) with offline support
- Silver purities (999, 958, 925, 800) and currency exchange rates
- Multi-currency display (EGP, SAR)
- Karat calculator
- Email/password auth + guest mode (Firebase)
- Arabic & English with full RTL support
- Light & dark themes

## Architecture
Clean Architecture + MVVM, with BLoC/Cubit for state management.

lib/
├── core/          # DI, theme, network, cache, errors
└── features/
├── auth/      # data / domain / presentation
├── gold_prices/
└── calculator/

## Tech Stack
Flutter · Dart · BLoC · Dio · Hive · Firebase Auth · get_it · dartz

## Data Source
Prices from the [XAUS API](https://api.gold-api.com/price/XAU). Indicative mid-market
rates — not tradable quotes.

## Getting Started
```bash
flutter pub get
flutter run
```

## Author
Ali Khaled Ibn Al-Walid — Flutter Developer
