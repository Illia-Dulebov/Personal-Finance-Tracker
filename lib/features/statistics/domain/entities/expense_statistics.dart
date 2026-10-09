import 'package:equatable/equatable.dart';

import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/category.dart';

class CategorySpending extends Equatable {
  final Category category;
  final double amountInAll;

  const CategorySpending({required this.category, required this.amountInAll});

  @override
  List<Object?> get props => [category, amountInAll];
}

class MonthlySpending extends Equatable {
  final DateTime month;
  final double amountInAll;

  const MonthlySpending({required this.month, required this.amountInAll});

  @override
  List<Object?> get props => [month, amountInAll];
}

class CurrencySpending extends Equatable {
  final CurrencyCode currency;
  final double originalAmount;

  const CurrencySpending({
    required this.currency,
    required this.originalAmount,
  });

  @override
  List<Object?> get props => [currency, originalAmount];
}

class ExpenseStatistics extends Equatable {
  final double totalInAll;
  final List<CategorySpending> categorySpending;
  final List<MonthlySpending> monthlySpending;
  final List<CurrencySpending> currencyDistribution;
  final List<Category> availableCategories;
  final int expenseCount;
  final int unconvertedExpenseCount;

  const ExpenseStatistics({
    required this.totalInAll,
    required this.categorySpending,
    required this.monthlySpending,
    required this.currencyDistribution,
    required this.availableCategories,
    required this.expenseCount,
    required this.unconvertedExpenseCount,
  });

  @override
  List<Object?> get props => [
    totalInAll,
    categorySpending,
    monthlySpending,
    currencyDistribution,
    availableCategories,
    expenseCount,
    unconvertedExpenseCount,
  ];
}
