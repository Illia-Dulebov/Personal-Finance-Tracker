import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'package:personal_finance_tracker/features/budgets/data/data_sources/local/budget_local_data_source.dart';
import 'package:personal_finance_tracker/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:personal_finance_tracker/features/budgets/domain/usecases/get_monthly_budget_overview.dart';
import 'package:personal_finance_tracker/features/budgets/domain/usecases/save_monthly_budget.dart';
import 'package:personal_finance_tracker/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:personal_finance_tracker/features/budgets/presentation/screens/budget_screen.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/repositories/expense_repository.dart';

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

  late BudgetCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final budgetRepository = BudgetRepositoryImpl(
      localDataSource: BudgetLocalDataSource(prefs: preferences),
    );
    final category = AppConstants.defaultCategories.first;
    final expenseRepository = _FakeExpenseRepository([
      Expense(
        id: 'food-expense',
        amount: 50,
        currency: CurrencyCode.all,
        date: DateTime(2026, 3, 12),
        category: category,
        paymentMethod: PaymentMethod.cash,
        description: '',
        amountInBaseCurrency: 50,
        conversionBaseCurrency: CurrencyCode.all,
      ),
    ]);
    cubit = BudgetCubit(
      getMonthlyBudgetOverviewUseCase: GetMonthlyBudgetOverviewUseCase(
        budgetRepository: budgetRepository,
        expenseRepository: expenseRepository,
      ),
      saveMonthlyBudgetUseCase: SaveMonthlyBudgetUseCase(budgetRepository),
      initialMonth: DateTime(2026, 3, 15),
    );
  });

  tearDown(() => cubit.close());

  testWidgets('shows spending without a limit and supports setting a budget', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const BudgetScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('March 2026'), findsOneWidget);
    expect(find.text('Spent: 50.00 ALL'), findsOneWidget);
    expect(find.text('No limit configured'), findsOneWidget);

    await tester.tap(find.text('Set budget').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '100');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Budget: 100.00 ALL'), findsOneWidget);
    expect(find.text('Remaining: 50.00 ALL'), findsOneWidget);
    expect(find.text('No limit configured'), findsNothing);
  });
}
