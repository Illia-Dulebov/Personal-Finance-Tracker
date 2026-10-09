import '../../../../core/constants/app_constants.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../expenses/domain/utils/expense_amount_converter.dart';
import '../entities/expense_statistics.dart';
import '../entities/statistics_filter.dart';

class GetExpenseStatisticsUseCase {
  final ExpenseRepository expenseRepository;

  const GetExpenseStatisticsUseCase(this.expenseRepository);

  Future<ExpenseStatistics> call(StatisticsFilter filter) async {
    final allExpenses = await expenseRepository.getExpenses();
    final categoriesById = {
      for (final category in AppConstants.defaultCategories)
        category.id: category,
      for (final expense in allExpenses) expense.category.id: expense.category,
    };
    final expenses = allExpenses.where((expense) {
      return !expense.date.isBefore(filter.startDate) &&
          expense.date.isBefore(filter.endDateExclusive) &&
          (filter.categoryId == null ||
              expense.category.id == filter.categoryId) &&
          (filter.currency == null || expense.currency == filter.currency);
    }).toList();

    var totalInAll = 0.0;
    var unconvertedExpenseCount = 0;
    final categoryTotals = <String, double>{};
    final monthlyTotals = <DateTime, double>{};
    final currencyTotals = <String, double>{};

    for (final expense in expenses) {
      currencyTotals.update(
        expense.currency.value,
        (amount) => amount + expense.amount,
        ifAbsent: () => expense.amount,
      );
      final baseAmount = amountInAll(expense);
      if (baseAmount == null) {
        unconvertedExpenseCount++;
        continue;
      }

      totalInAll += baseAmount;
      categoryTotals.update(
        expense.category.id,
        (amount) => amount + baseAmount,
        ifAbsent: () => baseAmount,
      );
      final month = DateTime(expense.date.year, expense.date.month);
      monthlyTotals.update(
        month,
        (amount) => amount + baseAmount,
        ifAbsent: () => baseAmount,
      );
    }

    final categorySpending =
        categoryTotals.entries
            .map(
              (entry) => CategorySpending(
                category: categoriesById[entry.key]!,
                amountInAll: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.amountInAll.compareTo(a.amountInAll));

    final monthKeys = monthlyTotals.keys.toList()..sort();
    final monthlySpending = monthKeys
        .map(
          (month) =>
              MonthlySpending(month: month, amountInAll: monthlyTotals[month]!),
        )
        .toList();

    final currencySpending =
        currencyTotals.entries
            .map(
              (entry) => CurrencySpending(
                currency: expenses
                    .firstWhere(
                      (expense) => expense.currency.value == entry.key,
                    )
                    .currency,
                originalAmount: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => a.currency.value.compareTo(b.currency.value));

    return ExpenseStatistics(
      totalInAll: totalInAll,
      categorySpending: categorySpending,
      monthlySpending: monthlySpending,
      currencyDistribution: currencySpending,
      availableCategories: categoriesById.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name)),
      expenseCount: expenses.length,
      unconvertedExpenseCount: unconvertedExpenseCount,
    );
  }
}
