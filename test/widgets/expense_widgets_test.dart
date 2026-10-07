import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'package:personal_finance_tracker/features/currency/data/data_sources/static_currency_data_source.dart';
import 'package:personal_finance_tracker/features/currency/data/repositories/static_currency_repository.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/create_expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/delete_expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/get_expenses.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/update_expense.dart';
import 'package:personal_finance_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:personal_finance_tracker/features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'package:personal_finance_tracker/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:personal_finance_tracker/features/expenses/presentation/widgets/expense_item_card.dart';

class FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<List<Expense>> getExpenses() async => List.from(_expenses);

  @override
  Future<void> addExpense(Expense e) async => _expenses.add(e);

  @override
  Future<void> updateExpense(Expense e) async {
    final idx = _expenses.indexWhere((item) => item.id == e.id);
    if (idx != -1) _expenses[idx] = e;
  }

  @override
  Future<void> deleteExpense(String id) async =>
      _expenses.removeWhere((e) => e.id == id);
}

void main() {
  final sampleCategory = AppConstants.defaultCategories.first;

  final testExpense = Expense(
    id: 'test-1',
    amount: 150.0,
    currency: CurrencyCode.all,
    date: DateTime(2026, 3, 30, 12, 0),
    category: sampleCategory,
    paymentMethod: PaymentMethod.cash,
    description: 'Lunch with team',
  );

  group('1. ExpenseItemCard Widget Tests', () {
    testWidgets('Renders expense details correctly and handles callbacks', (
      tester,
    ) async {
      bool tapped = false;
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseItemCard(
              expense: testExpense,
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Verify text elements
      expect(find.text('🍔'), findsOneWidget);
      expect(find.text('Lunch with team'), findsOneWidget);
      expect(find.text('150.00 ALL'), findsOneWidget);
      expect(find.textContaining('Cash'), findsOneWidget);

      // Test card tap
      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);

      // Test delete icon tap
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });
  });

  group('2. AddEditExpenseScreen Form & Validation Tests', () {
    testWidgets('Shows validation errors on empty or invalid amount input', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddEditExpenseScreen(
            currencyRepository: StaticCurrencyRepository(
              dataSource: StaticCurrencyDataSource(),
            ),
          ),
        ),
      );

      // Tap Save without entering amount
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an amount'), findsOneWidget);

      // Enter invalid negative amount
      await tester.enterText(find.byType(TextFormField).first, '-50');
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Amount must be a positive number'), findsOneWidget);
    });

    testWidgets(
      'Edit Mode: Pre-fills data and enforces Currency Immutability',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AddEditExpenseScreen(
              expense: testExpense,
              currencyRepository: StaticCurrencyRepository(
                dataSource: StaticCurrencyDataSource(),
              ),
            ),
          ),
        );

        // Verify title shows Edit Expense
        expect(find.text('Wireframe: Edit Expense'), findsOneWidget);

        // Verify pre-filled description
        expect(find.text('Lunch with team'), findsOneWidget);

        // Verify Currency is immutable text and not an editable TextFormField
        expect(find.text('Currency: ALL (Immutable)'), findsOneWidget);
      },
    );

    testWidgets('Shows a base-currency estimate using the selected currency', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddEditExpenseScreen(
            currencyRepository: StaticCurrencyRepository(
              dataSource: StaticCurrencyDataSource(),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, '10');
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Approximate equivalent: 10.00 ALL'),
        findsOneWidget,
      );

      await tester.tap(find.byType(DropdownButtonFormField<CurrencyCode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR - Euro').last);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Approximate equivalent: 1000.00 ALL'),
        findsOneWidget,
      );
      expect(find.textContaining('reference rate; not live'), findsOneWidget);
    });
  });

  group('3. ExpenseListScreen View & State Tests', () {
    late FakeExpenseRepository fakeRepo;
    late ExpenseCubit cubit;

    setUp(() {
      fakeRepo = FakeExpenseRepository();
      cubit = ExpenseCubit(
        getExpensesUseCase: GetExpensesUseCase(fakeRepo as dynamic),
        createExpenseUseCase: CreateExpenseUseCase(
          fakeRepo as dynamic,
          StaticCurrencyRepository(dataSource: StaticCurrencyDataSource()),
        ),
        updateExpenseUseCase: UpdateExpenseUseCase(fakeRepo as dynamic),
        deleteExpenseUseCase: DeleteExpenseUseCase(fakeRepo as dynamic),
      );
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('Displays empty state message when list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ExpenseListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No expenses recorded yet.'), findsOneWidget);
    });

    testWidgets('Displays expense items when loaded', (tester) async {
      await fakeRepo.addExpense(testExpense);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ExpenseListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lunch with team'), findsOneWidget);
      expect(find.text('150.00 ALL'), findsOneWidget);
    });
  });
}
