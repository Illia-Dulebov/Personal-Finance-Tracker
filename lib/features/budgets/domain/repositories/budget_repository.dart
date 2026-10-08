import '../entities/monthly_budget.dart';

abstract class BudgetRepository {
  Future<List<MonthlyBudget>> getBudgetsForMonth(DateTime month);
  Future<void> saveBudget(MonthlyBudget budget);
}
