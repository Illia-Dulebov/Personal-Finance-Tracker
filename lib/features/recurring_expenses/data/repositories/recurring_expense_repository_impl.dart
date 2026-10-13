import '../../domain/entities/recurring_expense_rule.dart';
import '../../domain/repositories/recurring_expense_repository.dart';
import '../data_sources/local/recurring_expense_local_data_source.dart';
import '../models/recurring_expense_rule_model.dart';

class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseLocalDataSource localDataSource;

  RecurringExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<RecurringExpenseRule>> getRules() async =>
      localDataSource.getRules();

  @override
  Future<void> saveRule(RecurringExpenseRule rule) async {
    final rules = (await localDataSource.getRules()).toList();
    final index = rules.indexWhere((existing) => existing.id == rule.id);
    final model = RecurringExpenseRuleModel.fromEntity(rule);
    if (index == -1) {
      rules.add(model);
    } else {
      rules[index] = model;
    }
    await localDataSource.saveRules(rules);
  }

  @override
  Future<void> deleteRule(String id) async {
    final rules = (await localDataSource.getRules()).toList()
      ..removeWhere((rule) => rule.id == id);
    await localDataSource.saveRules(rules);
  }
}
