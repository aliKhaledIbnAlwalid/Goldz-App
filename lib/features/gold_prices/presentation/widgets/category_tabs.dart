import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/market_category/category_cubit.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../domain/entities/price_item.dart';
import '../utils/asset_labels.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return BlocBuilder<CategoryCubit, MarketCategory>(
      builder: (context, selectedCategory) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: MarketCategory.values.map((category) {
              final selected = category == selectedCategory;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<CategoryCubit>().select(category),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected ? c.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: c.cardShadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      categoryLabel(context, category),
                      textAlign: TextAlign.center,
                      style: AppText.label(
                        13.5,
                        color:
                            selected ? c.textPrimary : c.textSecondary,
                        weight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}