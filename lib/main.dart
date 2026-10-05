import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart';
import 'features/expenses/presentation/screens/expense_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => sl<ExpenseCubit>(),
        child: const ExpenseListScreen(),
      ),
    );
  }
}
