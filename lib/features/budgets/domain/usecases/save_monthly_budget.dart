import '../entities/monthly_budget.dart';
import '../repositories/budget_repository.dart';

class SaveMonthlyBudgetUseCase {
  final BudgetRepository repository;

  SaveMonthlyBudgetUseCase(this.repository);

  Future<void> call(MonthlyBudget budget) async {
    if (!budget.amount.isFinite || budget.amount <= 0) {
      throw ArgumentError.value(
        budget.amount,
        'amount',
        'Must be a finite positive amount',
      );
    }
    await repository.saveBudget(budget);
  }
}
