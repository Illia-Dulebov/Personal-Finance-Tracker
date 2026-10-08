import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'package:personal_finance_tracker/features/budgets/data/data_sources/local/budget_local_data_source.dart';
import 'package:personal_finance_tracker/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:personal_finance_tracker/features/budgets/domain/entities/monthly_budget.dart';
import 'package:personal_finance_tracker/features/budgets/domain/usecases/get_monthly_budget_overview.dart';
import 'package:personal_finance_tracker/features/budgets/domain/usecases/save_monthly_budget.dart';
import 'package:personal_finance_tracker/features/expenses/data/models/expense_model.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';

class _FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> expenses;

  _FakeExpenseRepository(this.expenses);

  @override
  Future<List<Expense>> getExpenses() async => expenses;

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late BudgetLocalDataSource localDataSource;
  late BudgetRepositoryImpl budgetRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    localDataSource = BudgetLocalDataSource(prefs: preferences);
    budgetRepository = BudgetRepositoryImpl(localDataSource: localDataSource);
  });

  test('saves and updates one category budget for the same month', () async {
    final category = AppConstants.defaultCategories.first;
    final march = MonthlyBudget(
      category: category,
      month: DateTime(2026, 3, 20),
      amount: 1000,
    );
    await budgetRepository.saveBudget(march);
    await budgetRepository.saveBudget(
      MonthlyBudget(category: category, month: DateTime(2026, 3), amount: 1500),
    );

    final saved = await budgetRepository.getBudgetsForMonth(
      DateTime(2026, 3, 31),
    );
    expect(saved, hasLength(1));
    expect(saved.single.amount, 1500);
    expect(saved.single.month, DateTime(2026, 3));
    expect(
      await budgetRepository.getBudgetsForMonth(DateTime(2026, 4)),
      isEmpty,
    );
  });

  test('persists a budget across repository instances', () async {
    final category = AppConstants.defaultCategories.first;
    await budgetRepository.saveBudget(
      MonthlyBudget(category: category, month: DateTime(2026, 3), amount: 200),
    );

    final restoredRepository = BudgetRepositoryImpl(
      localDataSource: BudgetLocalDataSource(prefs: preferences),
    );
    expect(
      (await restoredRepository.getBudgetsForMonth(
        DateTime(2026, 3),
      )).single.amount,
      200,
    );
  });

  test('loads known legacy category IDs with canonical category details', () {
    final expense = ExpenseModel.fromJson({
      'id': 'legacy-category',
      'amount': 20,
      'currency': 'ALL',
      'date': '2026-03-10T00:00:00.000',
      'category': {'id': 'food', 'name': 'Food & Dining', 'emoji': '🍔'},
      'paymentMethod': 'Cash',
      'description': '',
    });

    expect(expense.category.name, 'Food');
    expect(expense.category.emoji, '🍔');
  });

  test('rejects non-positive and non-finite budget amounts', () async {
    final useCase = SaveMonthlyBudgetUseCase(budgetRepository);
    final category = AppConstants.defaultCategories.first;
    for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
      await expectLater(
        useCase(
          MonthlyBudget(
            category: category,
            month: DateTime(2026, 3),
            amount: amount,
          ),
        ),
        throwsArgumentError,
      );
    }
  });

  test(
    'aggregates calendar-month spending using saved historical conversion',
    () async {
      final category = AppConstants.defaultCategories.first;
      final otherMonthExpense = Expense(
        id: 'outside',
        amount: 30,
        currency: CurrencyCode.all,
        date: DateTime(2026, 4, 1),
        category: category,
        paymentMethod: PaymentMethod.cash,
        description: '',
      );
      final expenses = [
        Expense(
          id: 'all',
          amount: 100,
          currency: CurrencyCode.all,
          date: DateTime(2026, 3, 1),
          category: category,
          paymentMethod: PaymentMethod.cash,
          description: '',
          amountInBaseCurrency: 100,
          exchangeRateToBaseCurrency: 1,
          conversionBaseCurrency: CurrencyCode.all,
        ),
        Expense(
          id: 'eur',
          amount: 10,
          currency: CurrencyCode.eur,
          date: DateTime(2026, 3, 31, 23, 59),
          category: category,
          paymentMethod: PaymentMethod.cash,
          description: '',
          amountInBaseCurrency: 1200,
          exchangeRateToBaseCurrency: 120,
          conversionBaseCurrency: CurrencyCode.all,
        ),
        Expense(
          id: 'unconverted',
          amount: 500,
          currency: CurrencyCode.eur,
          date: DateTime(2026, 3, 12),
          category: category,
          paymentMethod: PaymentMethod.cash,
          description: '',
        ),
        otherMonthExpense,
      ];
      await budgetRepository.saveBudget(
        MonthlyBudget(
          category: category,
          month: DateTime(2026, 3),
          amount: 1000,
        ),
      );
      final useCase = GetMonthlyBudgetOverviewUseCase(
        budgetRepository: budgetRepository,
        expenseRepository: _FakeExpenseRepository(expenses),
      );

      final summary = (await useCase(
        DateTime(2026, 3, 15),
      )).firstWhere((item) => item.category.id == category.id);

      expect(summary.spending, 1300);
      expect(summary.budgetAmount, 1000);
      expect(summary.remainingAmount, -300);
      expect(summary.isOverBudget, isTrue);
    },
  );

  test(
    'keeps legacy ALL spending and reports spending without a budget',
    () async {
      final category = AppConstants.defaultCategories.first;
      final expense = Expense(
        id: 'legacy',
        amount: 75,
        currency: CurrencyCode.all,
        date: DateTime(2026, 3, 15),
        category: category,
        paymentMethod: PaymentMethod.cash,
        description: '',
      );
      final useCase = GetMonthlyBudgetOverviewUseCase(
        budgetRepository: budgetRepository,
        expenseRepository: _FakeExpenseRepository([expense]),
      );

      final summary = (await useCase(
        DateTime(2026, 3),
      )).firstWhere((item) => item.category.id == category.id);

      expect(summary.spending, 75);
      expect(summary.budgetAmount, isNull);
      expect(summary.remainingAmount, isNull);
      expect(summary.isOverBudget, isFalse);
    },
  );
}
