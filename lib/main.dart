import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/budgets/presentation/cubit/budget_cubit.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ExpenseCubit>()),
        BlocProvider(create: (_) => sl<BudgetCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Personal Finance Tracker',
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
