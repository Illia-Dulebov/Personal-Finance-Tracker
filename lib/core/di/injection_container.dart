import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/currency/data/data_sources/static_currency_data_source.dart';
import '../../features/currency/data/repositories/static_currency_repository.dart';
import '../../features/currency/domain/repositories/currency_repository.dart';
import '../../features/budgets/data/data_sources/local/budget_local_data_source.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/domain/usecases/get_monthly_budget_overview.dart';
import '../../features/budgets/domain/usecases/save_monthly_budget.dart';
import '../../features/budgets/presentation/cubit/budget_cubit.dart';
import '../../features/expenses/data/data_sources/local/expense_local_data_source.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/create_expense.dart';
import '../../features/expenses/domain/usecases/delete_expense.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/update_expense.dart';
import '../../features/expenses/presentation/cubit/expense_cubit.dart';
import '../../features/statistics/domain/usecases/get_expense_statistics.dart';
import '../../features/statistics/presentation/cubit/statistics_cubit.dart';
import '../../features/recurring_expenses/data/data_sources/local/recurring_expense_local_data_source.dart';
import '../../features/recurring_expenses/data/repositories/recurring_expense_repository_impl.dart';
import '../../features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';
import '../../features/recurring_expenses/domain/repositories/generated_expense_store.dart';
import '../../features/recurring_expenses/domain/usecases/process_due_recurring_expenses.dart';
import '../../features/recurring_expenses/domain/usecases/save_recurring_expense_rule.dart';
import '../../features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // --------------------------------------------------------------------------
  // External
  // --------------------------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // --------------------------------------------------------------------------
  // Data Sources
  // --------------------------------------------------------------------------
  sl.registerLazySingleton<StaticCurrencyDataSource>(
    () => StaticCurrencyDataSource(),
  );

  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSource(prefs: sl()),
  );
  sl.registerLazySingleton<RecurringExpenseLocalDataSource>(
    () => RecurringExpenseLocalDataSource(prefs: sl()),
  );

  // --------------------------------------------------------------------------
  // Repositories
  // --------------------------------------------------------------------------
  sl.registerLazySingleton<CurrencyRepository>(
    () => StaticCurrencyRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<ExpenseRepositoryImpl>(
    () => ExpenseRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => sl<ExpenseRepositoryImpl>(),
  );
  sl.registerLazySingleton<GeneratedExpenseStore>(
    () => sl<ExpenseRepositoryImpl>(),
  );
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<RecurringExpenseRepository>(
    () => RecurringExpenseRepositoryImpl(localDataSource: sl()),
  );

  // --------------------------------------------------------------------------
  // Use Cases
  // --------------------------------------------------------------------------
  sl.registerFactory(() => GetExpensesUseCase(sl()));
  sl.registerFactory(() => CreateExpenseUseCase(sl(), sl()));
  sl.registerFactory(() => UpdateExpenseUseCase(sl()));
  sl.registerFactory(() => DeleteExpenseUseCase(sl()));
  sl.registerFactory(
    () => GetMonthlyBudgetOverviewUseCase(
      budgetRepository: sl(),
      expenseRepository: sl(),
    ),
  );
  sl.registerFactory(() => SaveMonthlyBudgetUseCase(sl()));
  sl.registerFactory(() => GetExpenseStatisticsUseCase(sl()));
  sl.registerFactory(() => SaveRecurringExpenseRuleUseCase(sl()));
  sl.registerLazySingleton(
    () => ProcessDueRecurringExpensesUseCase(
      recurringExpenseRepository: sl(),
      expenseRepository: sl(),
      generatedExpenseStore: sl(),
      createExpenseUseCase: sl(),
    ),
  );

  // --------------------------------------------------------------------------
  // Cubit
  // --------------------------------------------------------------------------
  sl.registerFactory(
    () => ExpenseCubit(
      getExpensesUseCase: sl(),
      createExpenseUseCase: sl(),
      updateExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
      processDueRecurringExpensesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => BudgetCubit(
      getMonthlyBudgetOverviewUseCase: sl(),
      saveMonthlyBudgetUseCase: sl(),
    ),
  );
  sl.registerFactory(() => StatisticsCubit(getExpenseStatisticsUseCase: sl()));
  sl.registerFactory(
    () => RecurringExpenseCubit(repository: sl(), saveRuleUseCase: sl()),
  );
}
