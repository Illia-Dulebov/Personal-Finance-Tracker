import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../expenses/domain/usecases/create_expense.dart';
import '../repositories/generated_expense_store.dart';
import '../repositories/recurring_expense_repository.dart';
import '../utils/recurrence_schedule.dart';

class ProcessDueRecurringExpensesUseCase {
  final RecurringExpenseRepository recurringExpenseRepository;
  final ExpenseRepository expenseRepository;
  final GeneratedExpenseStore generatedExpenseStore;
  final CreateExpenseUseCase createExpenseUseCase;
  final DateTime Function() clock;
  Future<void>? _processing;

  ProcessDueRecurringExpensesUseCase({
    required this.recurringExpenseRepository,
    required this.expenseRepository,
    required this.generatedExpenseStore,
    required this.createExpenseUseCase,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  Future<void> call() {
    return _processing ??= _process().whenComplete(() {
      _processing = null;
    });
  }

  Future<void> _process() async {
    final today = _dateOnly(clock());
    final rules = await recurringExpenseRepository.getRules();
    for (final rule in rules) {
      var nextDate = _dateOnly(rule.nextGenerationDate);
      var lastGeneratedDate = rule.lastGeneratedDate;
      while (!nextDate.isAfter(today)) {
        final occurrenceKey = _occurrenceKey(rule.id, nextDate);
        if (!await generatedExpenseStore.hasOccurrence(occurrenceKey)) {
          final expense = Expense(
            id: const Uuid().v4(),
            amount: rule.amount,
            currency: rule.currency,
            date: nextDate,
            category: rule.category,
            paymentMethod: rule.paymentMethod,
            description: rule.description,
          );
          await generatedExpenseStore.saveGeneratedExpense(
            await createExpenseUseCase.prepareExpense(expense),
            occurrenceKey,
          );
        }
        lastGeneratedDate = nextDate;
        final following = RecurrenceSchedule.nextOccurrence(rule, nextDate);
        final updatedRule = rule.copyWith(
          lastGeneratedDate: lastGeneratedDate,
          nextGenerationDate: following,
        );
        await recurringExpenseRepository.saveRule(updatedRule);
        nextDate = following;
      }
    }
  }

  static String _occurrenceKey(String ruleId, DateTime date) => jsonEncode([
    ruleId,
    '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}',
  ]);

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
