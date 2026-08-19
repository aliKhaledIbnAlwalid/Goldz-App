import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/gold_prices/domain/entities/price_item.dart';

/// Shared between Home and All Prices so switching to Gold on one
/// screen is reflected on the other.
class CategoryCubit extends Cubit<MarketCategory> {
  CategoryCubit() : super(MarketCategory.gold);

  void select(MarketCategory category) => emit(category);
}