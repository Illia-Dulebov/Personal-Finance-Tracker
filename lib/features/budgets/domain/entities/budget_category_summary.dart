import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/category.dart';

class BudgetCategorySummary extends Equatable {
  final Category category;
  final double spending;
  final double? budgetAmount;

  const BudgetCategorySummary({
    required this.category,
    required this.spending,
    required this.budgetAmount,
  });

  double? get remainingAmount =>
      budgetAmount == null ? null : budgetAmount! - spending;

  bool get isOverBudget => budgetAmount != null && spending > budgetAmount!;

  @override
  List<Object?> get props => [category, spending, budgetAmount];
}
