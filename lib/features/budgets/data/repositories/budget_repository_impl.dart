import '../../domain/entities/monthly_budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../data_sources/local/budget_local_data_source.dart';
import '../models/monthly_budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MonthlyBudget>> getBudgetsForMonth(DateTime month) async {
    final period = DateTime(month.year, month.month);
    final models = await localDataSource.getBudgets();
    return models
        .where(
          (budget) =>
              budget.month.year == period.year &&
              budget.month.month == period.month,
        )
        .map((budget) => budget.toEntity())
        .toList();
  }

  @override
  Future<void> saveBudget(MonthlyBudget budget) async {
    final models = await localDataSource.getBudgets();
    final index = models.indexWhere(
      (existing) =>
          existing.category.id == budget.category.id &&
          existing.month.year == budget.month.year &&
          existing.month.month == budget.month.month,
    );
    final model = MonthlyBudgetModel.fromEntity(budget);
    if (index == -1) {
      models.add(model);
    } else {
      models[index] = model;
    }
    await localDataSource.saveBudgets(models);
  }
}
