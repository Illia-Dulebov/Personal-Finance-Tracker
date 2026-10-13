import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'package:personal_finance_tracker/features/currency/data/data_sources/static_currency_data_source.dart';
import 'package:personal_finance_tracker/features/currency/data/repositories/static_currency_repository.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';
import 'package:personal_finance_tracker/features/expenses/data/data_sources/local/expense_local_data_source.dart';
import 'package:personal_finance_tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/create_expense.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/data/data_sources/local/recurring_expense_local_data_source.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/data/repositories/recurring_expense_repository_impl.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/domain/entities/recurring_expense_rule.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/domain/entities/recurring_frequency.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/domain/usecases/process_due_recurring_expenses.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/domain/usecases/save_recurring_expense_rule.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/domain/utils/recurrence_schedule.dart';

class _FailOnceRuleRepository implements RecurringExpenseRepository {
  final RecurringExpenseRule rule;
  bool shouldFailNextSave = true;
  RecurringExpenseRule currentRule;

  _FailOnceRuleRepository(this.rule) : currentRule = rule;

  @override
  Future<List<RecurringExpenseRule>> getRules() async => [currentRule];

  @override
  Future<void> saveRule(RecurringExpenseRule updatedRule) async {
    if (shouldFailNextSave) {
      shouldFailNextSave = false;
      throw StateError('Simulated interruption after expense persistence');
    }
    currentRule = updatedRule;
  }

  @override
  Future<void> deleteRule(String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late ExpenseRepositoryImpl expenseRepository;
  late RecurringExpenseRepositoryImpl recurringRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    expenseRepository = ExpenseRepositoryImpl(
      localDataSource: ExpenseLocalDataSourceImpl(prefs: preferences),
    );
    recurringRepository = RecurringExpenseRepositoryImpl(
      localDataSource: RecurringExpenseLocalDataSource(prefs: preferences),
    );
  });

  final category = AppConstants.defaultCategories.first;

  RecurringExpenseRule rule({
    RecurringFrequency frequency = RecurringFrequency.daily,
    int? scheduleDay,
    DateTime? nextDate,
  }) => RecurringExpenseRule(
    id: 'monthly-bill',
    amount: 25,
    currency: CurrencyCode.all,
    category: category,
    paymentMethod: PaymentMethod.card,
    description: 'Subscription',
    frequency: frequency,
    scheduleDay: scheduleDay,
    lastGeneratedDate: null,
    nextGenerationDate: nextDate ?? DateTime(2026, 3, 10),
  );

  test(
    'clamps short monthly dates and restores the selected day afterward',
    () {
      final monthlyRule = rule(
        frequency: RecurringFrequency.monthly,
        scheduleDay: 31,
      );

      expect(
        RecurrenceSchedule.nextOccurrence(monthlyRule, DateTime(2026, 1, 31)),
        DateTime(2026, 2, 28),
      );
      expect(
        RecurrenceSchedule.nextOccurrence(monthlyRule, DateTime(2026, 2, 28)),
        DateTime(2026, 3, 31),
      );
      expect(
        RecurrenceSchedule.nextOccurrence(monthlyRule, DateTime(2024, 1, 31)),
        DateTime(2024, 2, 29),
      );
    },
  );

  test('persists rules across repository instances', () async {
    final savedRule = rule(
      frequency: RecurringFrequency.monthly,
      scheduleDay: 31,
    );
    await recurringRepository.saveRule(savedRule);
    final restored = RecurringExpenseRepositoryImpl(
      localDataSource: RecurringExpenseLocalDataSource(prefs: preferences),
    );

    final restoredRule = (await restored.getRules()).single;
    expect(restoredRule.id, savedRule.id);
    expect(restoredRule.amount, savedRule.amount);
    expect(restoredRule.frequency, savedRule.frequency);
    expect(restoredRule.scheduleDay, savedRule.scheduleDay);
    expect(restoredRule.nextGenerationDate, savedRule.nextGenerationDate);
  });

  test('validates amounts and frequency-specific schedule days', () async {
    final useCase = SaveRecurringExpenseRuleUseCase(recurringRepository);
    await expectLater(
      useCase(rule().copyWith(amount: double.infinity)),
      throwsArgumentError,
    );
    await expectLater(
      useCase(rule(frequency: RecurringFrequency.weekly, scheduleDay: 8)),
      throwsArgumentError,
    );
    await expectLater(
      useCase(rule(frequency: RecurringFrequency.monthly, scheduleDay: 32)),
      throwsArgumentError,
    );
  });

  test('catches up every missed daily occurrence', () async {
    final dueRule = rule(nextDate: DateTime(2026, 3, 10));
    await recurringRepository.saveRule(dueRule);
    final currencyRepository = StaticCurrencyRepository(
      dataSource: StaticCurrencyDataSource(),
      clock: () => DateTime(2026, 3, 12),
    );
    final process = ProcessDueRecurringExpensesUseCase(
      recurringExpenseRepository: recurringRepository,
      expenseRepository: expenseRepository,
      generatedExpenseStore: expenseRepository,
      createExpenseUseCase: CreateExpenseUseCase(
        expenseRepository,
        currencyRepository,
      ),
      clock: () => DateTime(2026, 3, 12),
    );

    await process();

    final expenses = await expenseRepository.getExpenses();
    expect(expenses.map((expense) => expense.date).toList(), [
      DateTime(2026, 3, 12),
      DateTime(2026, 3, 11),
      DateTime(2026, 3, 10),
    ]);
    final savedRule = (await recurringRepository.getRules()).single;
    expect(savedRule.lastGeneratedDate, DateTime(2026, 3, 12));
    expect(savedRule.nextGenerationDate, DateTime(2026, 3, 13));
  });

  test(
    'retry after rule-save failure does not duplicate generated expense',
    () async {
      final dueRule = rule();
      final retryableRuleRepository = _FailOnceRuleRepository(dueRule);
      final currencyRepository = StaticCurrencyRepository(
        dataSource: StaticCurrencyDataSource(),
        clock: () => DateTime(2026, 3, 10),
      );
      final process = ProcessDueRecurringExpensesUseCase(
        recurringExpenseRepository: retryableRuleRepository,
        expenseRepository: expenseRepository,
        generatedExpenseStore: expenseRepository,
        createExpenseUseCase: CreateExpenseUseCase(
          expenseRepository,
          currencyRepository,
        ),
        clock: () => DateTime(2026, 3, 10),
      );

      await expectLater(process(), throwsStateError);
      expect(await expenseRepository.getExpenses(), hasLength(1));
      await process();

      expect(await expenseRepository.getExpenses(), hasLength(1));
      expect(
        retryableRuleRepository.currentRule.nextGenerationDate,
        DateTime(2026, 3, 11),
      );
    },
  );

  test(
    'deleting a generated expense does not erase its processed marker',
    () async {
      const occurrenceKey = '["monthly-bill","2026-03-10"]';
      final generatedExpense = Expense(
        id: 'generated',
        amount: 25,
        currency: CurrencyCode.all,
        date: DateTime(2026, 3, 10),
        category: category,
        paymentMethod: PaymentMethod.card,
        description: 'Subscription',
      );
      await expenseRepository.saveGeneratedExpense(
        generatedExpense,
        occurrenceKey,
      );
      await expenseRepository.deleteExpense(generatedExpense.id);

      expect(await expenseRepository.getExpenses(), isEmpty);
      expect(await expenseRepository.hasOccurrence(occurrenceKey), isTrue);
    },
  );

  test('supports exact day selection for weekly and monthly rules', () {
    expect(
      RecurrenceSchedule.firstOccurrenceOnOrAfter(
        RecurringFrequency.weekly,
        DateTime.sunday,
        DateTime(2026, 3, 10),
      ),
      DateTime(2026, 3, 15),
    );
    expect(
      RecurrenceSchedule.firstOccurrenceOnOrAfter(
        RecurringFrequency.monthly,
        31,
        DateTime(2026, 2, 15),
      ),
      DateTime(2026, 2, 28),
    );
  });
}
