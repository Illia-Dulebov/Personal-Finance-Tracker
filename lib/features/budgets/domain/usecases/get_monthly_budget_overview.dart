import '../../../../core/constants/app_constants.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../entities/budget_category_summary.dart';
import '../repositories/budget_repository.dart';

class GetMonthlyBudgetOverviewUseCase {
  final BudgetRepository budgetRepository;
  final ExpenseRepository expenseRepository;

  GetMonthlyBudgetOverviewUseCase({
    required this.budgetRepository,
    required this.expenseRepository,
  });

  Future<List<BudgetCategorySummary>> call(DateTime month) async {
    final periodStart = DateTime(month.year, month.month);
    final periodEnd = DateTime(month.year, month.month + 1);
    final budgets = await budgetRepository.getBudgetsForMonth(periodStart);
    final expenses = await expenseRepository.getExpenses();
    final categoryById = {
      for (final category in AppConstants.defaultCategories)
        category.id: category,
    };
    for (final expense in expenses) {
      categoryById.putIfAbsent(expense.category.id, () => expense.category);
    }
    for (final budget in budgets) {
      categoryById.putIfAbsent(budget.category.id, () => budget.category);
    }
    final spendingByCategory = <String, double>{};

    for (final expense in expenses) {
      if (!_isInPeriod(expense, periodStart, periodEnd)) {
        continue;
      }
      final amountInBaseCurrency = _amountInBaseCurrency(expense);
      if (amountInBaseCurrency == null) {
        continue;
      }
      spendingByCategory.update(
        expense.category.id,
        (amount) => amount + amountInBaseCurrency,
        ifAbsent: () => amountInBaseCurrency,
      );
    }

    final budgetsByCategory = {
      for (final budget in budgets) budget.category.id: budget,
    };

    return categoryById.values.map((category) {
      return BudgetCategorySummary(
        category: category,
        spending: spendingByCategory[category.id] ?? 0,
        budgetAmount: budgetsByCategory[category.id]?.amount,
      );
    }).toList();
  }

  bool _isInPeriod(Expense expense, DateTime start, DateTime end) {
    return !expense.date.isBefore(start) && expense.date.isBefore(end);
  }

  double? _amountInBaseCurrency(Expense expense) {
    if (expense.conversionBaseCurrency == CurrencyCode.all) {
      return expense.amountInBaseCurrency ??
          (expense.currency == CurrencyCode.all ? expense.amount : null);
    }
    if (expense.currency == CurrencyCode.all &&
        expense.conversionBaseCurrency == null) {
      return expense.amountInBaseCurrency ?? expense.amount;
    }
    return null;
  }
}
