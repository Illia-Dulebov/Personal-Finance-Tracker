import '../entities/recurring_expense_rule.dart';

abstract class RecurringExpenseRepository {
  Future<List<RecurringExpenseRule>> getRules();
  Future<void> saveRule(RecurringExpenseRule rule);
  Future<void> deleteRule(String id);
}
