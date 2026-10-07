import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'package:personal_finance_tracker/features/currency/data/data_sources/static_currency_data_source.dart';
import 'package:personal_finance_tracker/features/currency/data/repositories/static_currency_repository.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';
import 'package:personal_finance_tracker/features/expenses/data/data_sources/local/expense_local_data_source.dart';
import 'package:personal_finance_tracker/features/expenses/data/models/expense_model.dart';
import 'package:personal_finance_tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/create_expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/delete_expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/get_expenses.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/update_expense.dart';
import 'package:personal_finance_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:personal_finance_tracker/features/expenses/presentation/cubit/expense_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late ExpenseLocalDataSourceImpl dataSource;
  late ExpenseRepositoryImpl repository;
  late GetExpensesUseCase getExpensesUseCase;
  late CreateExpenseUseCase createExpenseUseCase;
  late UpdateExpenseUseCase updateExpenseUseCase;
  late DeleteExpenseUseCase deleteExpenseUseCase;
  late StaticCurrencyRepository currencyRepository;
  late ExpenseCubit cubit;

  final sampleCategory = AppConstants.defaultCategories.first;

  final testExpense1 = Expense(
    id: '1',
    amount: 100.0,
    currency: CurrencyCode.all,
    date: DateTime(2026, 3, 30, 10, 0),
    category: sampleCategory,
    paymentMethod: PaymentMethod.cash,
    description: 'Groceries',
    amountInBaseCurrency: 100.0,
    exchangeRateToBaseCurrency: 1.0,
    conversionBaseCurrency: CurrencyCode.all,
    conversionRateCapturedAt: DateTime(2026, 3, 30),
  );

  final testExpense2 = Expense(
    id: '2',
    amount: 250.0,
    currency: CurrencyCode.all,
    date: DateTime(2026, 3, 30, 15, 0),
    category: sampleCategory,
    paymentMethod: PaymentMethod.card,
    description: 'Bus ticket',
    amountInBaseCurrency: 250.0,
    exchangeRateToBaseCurrency: 1.0,
    conversionBaseCurrency: CurrencyCode.all,
    conversionRateCapturedAt: DateTime(2026, 3, 30),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = ExpenseLocalDataSourceImpl(prefs: prefs);
    repository = ExpenseRepositoryImpl(localDataSource: dataSource);

    currencyRepository = StaticCurrencyRepository(
      dataSource: StaticCurrencyDataSource(),
      clock: () => DateTime(2026, 3, 30),
    );
    getExpensesUseCase = GetExpensesUseCase(repository);
    createExpenseUseCase = CreateExpenseUseCase(repository, currencyRepository);
    updateExpenseUseCase = UpdateExpenseUseCase(repository);
    deleteExpenseUseCase = DeleteExpenseUseCase(repository);

    cubit = ExpenseCubit(
      getExpensesUseCase: getExpensesUseCase,
      createExpenseUseCase: createExpenseUseCase,
      updateExpenseUseCase: updateExpenseUseCase,
      deleteExpenseUseCase: deleteExpenseUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('1. Data Source & Serialization Tests', () {
    test('getExpenses returns empty list when key is uninitialized', () async {
      final expenses = await dataSource.getExpenses();
      expect(expenses, isEmpty);
    });

    test('ExpenseModel serializes to/from JSON map with ISO-8601 dates', () {
      final model = ExpenseModel.fromEntity(testExpense1);
      final jsonMap = model.toJson();

      expect(jsonMap['id'], '1');
      expect(jsonMap['amount'], 100.0);
      expect(jsonMap['currency'], 'ALL');
      expect(jsonMap['date'], testExpense1.date.toIso8601String());

      final restoredModel = ExpenseModel.fromJson(jsonMap);
      expect(restoredModel.id, model.id);
      expect(restoredModel.amount, model.amount);
      expect(restoredModel.date, model.date);
    });

    test('saveExpenses persists data in SharedPreferences', () async {
      final model = ExpenseModel.fromEntity(testExpense1);
      await dataSource.saveExpenses([model]);

      final retrieved = await dataSource.getExpenses();
      expect(retrieved.length, 1);
      expect(retrieved.first.id, '1');
    });
  });

  group('2. Repository & Sorting Tests', () {
    test('getExpenses sorts items descending by date (newest first)', () async {
      // testExpense2 has later timestamp than testExpense1
      await repository.addExpense(testExpense1);
      await repository.addExpense(testExpense2);

      final expenses = await repository.getExpenses();
      expect(expenses.length, 2);
      expect(expenses[0].id, '2'); // Newer item first
      expect(expenses[1].id, '1');
    });

    test('updateExpense modifies record in repository', () async {
      await repository.addExpense(testExpense1);
      final updated = testExpense1.copyWith(
        amount: 500.0,
        description: 'Updated Groceries',
      );

      await repository.updateExpense(updated);

      final expenses = await repository.getExpenses();
      expect(expenses.length, 1);
      expect(expenses.first.amount, 500.0);
      expect(expenses.first.description, 'Updated Groceries');
    });

    test('deleteExpense removes record from repository', () async {
      await repository.addExpense(testExpense1);
      var expenses = await repository.getExpenses();
      expect(expenses.length, 1);

      await repository.deleteExpense('1');
      expenses = await repository.getExpenses();
      expect(expenses, isEmpty);
    });
  });

  group('3. Use Cases Tests', () {
    test('Use cases delegate actions to repository', () async {
      await createExpenseUseCase(testExpense1);
      var expenses = await getExpensesUseCase();
      expect(expenses.length, 1);

      final updated = testExpense1.copyWith(
        amount: 300.0,
        amountInBaseCurrency: 300.0,
      );
      await updateExpenseUseCase(updated);
      expenses = await getExpensesUseCase();
      expect(expenses.first.amount, 300.0);

      await deleteExpenseUseCase('1');
      expenses = await getExpensesUseCase();
      expect(expenses, isEmpty);
    });
  });

  group('4. ExpenseCubit State Lifecycle Tests', () {
    test('Initial state is ExpenseInitialState', () {
      expect(cubit.state, const ExpenseInitialState());
    });

    test(
      'loadExpenses emits [Loading, Empty] when no expenses exist',
      () async {
        final expectedStates = [
          const ExpenseLoadingState(),
          const ExpenseEmptyState(),
        ];

        expectLater(cubit.stream, emitsInOrder(expectedStates));
        await cubit.loadExpenses();
      },
    );

    test('addExpense creates expense and emits [Loading, Loaded]', () async {
      final expectedStates = [
        const ExpenseLoadingState(),
        ExpenseLoadedState([testExpense1]),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.addExpense(testExpense1);
    });

    test(
      'updateExpense modifies expense and emits updated [Loading, Loaded]',
      () async {
        await cubit.addExpense(testExpense1);

        final updated = testExpense1.copyWith(
          amount: 800.0,
          amountInBaseCurrency: 800.0,
        );
        final expectedStates = [
          const ExpenseLoadingState(),
          ExpenseLoadedState([updated]),
        ];

        expectLater(cubit.stream, emitsInOrder(expectedStates));
        await cubit.updateExpense(updated);
      },
    );

    test(
      'deleteExpense removes last expense and emits [Loading, Empty]',
      () async {
        await cubit.addExpense(testExpense1);

        final expectedStates = [
          const ExpenseLoadingState(),
          const ExpenseEmptyState(),
        ];

        expectLater(cubit.stream, emitsInOrder(expectedStates));
        await cubit.deleteExpense('1');
      },
    );
  });
}
