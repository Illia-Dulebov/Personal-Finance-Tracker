import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../currency/domain/repositories/currency_repository.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_item_card.dart';
import 'add_edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseCubit>().loadExpenses();
  }

  Future<void> _navigateToAddExpense() async {
    final newExpense = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (_) =>
            AddEditExpenseScreen(currencyRepository: sl<CurrencyRepository>()),
      ),
    );

    if (newExpense != null && mounted) {
      context.read<ExpenseCubit>().addExpense(newExpense);
    }
  }

  Future<void> _navigateToEditExpense(Expense expense) async {
    final updatedExpense = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(
          expense: expense,
          currencyRepository: sl<CurrencyRepository>(),
        ),
      ),
    );

    if (updatedExpense != null && mounted) {
      context.read<ExpenseCubit>().updateExpense(updatedExpense);
    }
  }

  void _deleteExpense(String id) {
    context.read<ExpenseCubit>().deleteExpense(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wireframe: Personal Finance Tracker')),
      body: const _ExpenseListBody(),
      floatingActionButton: OutlinedButton.icon(
        onPressed: _navigateToAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _ExpenseListBody extends StatelessWidget {
  const _ExpenseListBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        return switch (state) {
          ExpenseInitialState() || ExpenseLoadingState() => const Center(
            child: CircularProgressIndicator(),
          ),
          ExpenseEmptyState() => const _EmptyStateView(),
          ExpenseErrorState(message: final msg) => _ErrorStateView(
            message: msg,
          ),
          ExpenseLoadedState(expenses: final expenses) => ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ExpenseItemCard(
                expense: expense,
                onTap: () => context
                    .findAncestorStateOfType<_ExpenseListScreenState>()
                    ?._navigateToEditExpense(expense),
                onDelete: () => context
                    .findAncestorStateOfType<_ExpenseListScreenState>()
                    ?._deleteExpense(expense.id),
              );
            },
          ),
        };
      },
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No expenses recorded yet.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _ErrorStateView extends StatelessWidget {
  final String message;

  const _ErrorStateView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }
}
