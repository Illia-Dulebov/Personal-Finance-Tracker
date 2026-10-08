import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'features/budgets/presentation/cubit/budget_cubit.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart';
import 'features/expenses/presentation/screens/expense_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<ExpenseCubit>()),
          BlocProvider(create: (_) => sl<BudgetCubit>()),
        ],
        child: const ExpenseListScreen(),
      ),
    );
  }
}
