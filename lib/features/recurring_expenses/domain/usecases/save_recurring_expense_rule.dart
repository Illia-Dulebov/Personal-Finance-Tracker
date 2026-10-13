import '../entities/recurring_expense_rule.dart';
import '../entities/recurring_frequency.dart';
import '../repositories/recurring_expense_repository.dart';

class SaveRecurringExpenseRuleUseCase {
  final RecurringExpenseRepository repository;

  SaveRecurringExpenseRuleUseCase(this.repository);

  Future<void> call(RecurringExpenseRule rule) async {
    if (!rule.amount.isFinite || rule.amount <= 0) {
      throw ArgumentError.value(
        rule.amount,
        'amount',
        'Must be a finite positive amount',
      );
    }
    final validSchedule = switch (rule.frequency) {
      RecurringFrequency.daily => rule.scheduleDay == null,
      RecurringFrequency.weekly =>
        rule.scheduleDay != null &&
            rule.scheduleDay! >= DateTime.monday &&
            rule.scheduleDay! <= DateTime.sunday,
      RecurringFrequency.monthly =>
        rule.scheduleDay != null &&
            rule.scheduleDay! >= 1 &&
            rule.scheduleDay! <= 31,
    };
    if (!validSchedule) {
      throw ArgumentError.value(
        rule.scheduleDay,
        'scheduleDay',
        'Invalid day for recurrence frequency',
      );
    }
    await repository.saveRule(rule);
  }
}
