import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../data_sources/local/expense_local_data_source.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Expense>> getExpenses() async {
    final models = await localDataSource.getExpenses();
    // Sort descending by date (newest first)
    models.sort((a, b) => b.date.compareTo(a.date));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final currentModels = await localDataSource.getExpenses();
    final newModel = ExpenseModel.fromEntity(expense);
    currentModels.add(newModel);
    await localDataSource.saveExpenses(currentModels);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final currentModels = await localDataSource.getExpenses();
    final index = currentModels.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      currentModels[index] = ExpenseModel.fromEntity(expense);
      await localDataSource.saveExpenses(currentModels);
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    final currentModels = await localDataSource.getExpenses();
    currentModels.removeWhere((e) => e.id == id);
    await localDataSource.saveExpenses(currentModels);
  }
}
