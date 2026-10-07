import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/currency/data/data_sources/static_currency_data_source.dart';
import '../../features/currency/data/repositories/static_currency_repository.dart';
import '../../features/currency/domain/repositories/currency_repository.dart';
import '../../features/expenses/data/data_sources/local/expense_local_data_source.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/create_expense.dart';
import '../../features/expenses/domain/usecases/delete_expense.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/update_expense.dart';
import '../../features/expenses/presentation/cubit/expense_cubit.dart';

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

  // --------------------------------------------------------------------------
  // Repositories
  // --------------------------------------------------------------------------
  sl.registerLazySingleton<CurrencyRepository>(
    () => StaticCurrencyRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(localDataSource: sl()),
  );

  // --------------------------------------------------------------------------
  // Use Cases
  // --------------------------------------------------------------------------
  sl.registerFactory(() => GetExpensesUseCase(sl()));
  sl.registerFactory(() => CreateExpenseUseCase(sl(), sl()));
  sl.registerFactory(() => UpdateExpenseUseCase(sl()));
  sl.registerFactory(() => DeleteExpenseUseCase(sl()));

  // --------------------------------------------------------------------------
  // Cubit
  // --------------------------------------------------------------------------
  sl.registerFactory(
    () => ExpenseCubit(
      getExpensesUseCase: sl(),
      createExpenseUseCase: sl(),
      updateExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
    ),
  );
}
