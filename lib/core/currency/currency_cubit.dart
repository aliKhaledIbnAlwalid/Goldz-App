import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_currencies.dart';

/// Holds the currency the user is viewing prices in.
/// A Cubit is enough here — one value, one action.
class CurrencyCubit extends Cubit<AppCurrency> {
  CurrencyCubit() : super(AppCurrencies.egp);

  void select(AppCurrency currency) => emit(currency);
}