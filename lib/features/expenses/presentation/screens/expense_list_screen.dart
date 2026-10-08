import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../../budgets/presentation/screens/budget_screen.dart';
import '../../../currency/domain/repositories/currency_repository.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/delete_expense_confirmation_dialog.dart';
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
      await context.read<ExpenseCubit>().addExpense(newExpense);
      await _refreshBudget();
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
      await context.read<ExpenseCubit>().updateExpense(updatedExpense);
      await _refreshBudget();
    }
  }

  Future<void> _confirmDeleteExpense(String id) async {
    final shouldDelete = await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => const DeleteExpenseConfirmationDialog(),
    );

    if (shouldDelete == true && mounted) {
      await context.read<ExpenseCubit>().deleteExpense(id);
      await _refreshBudget();
    }
  }

  Future<void> _refreshBudget() async {
    final budgetCubit = context.read<BudgetCubit?>();
    if (budgetCubit != null) {
      await budgetCubit.refresh();
    }
  }

  Future<void> _navigateToBudgets() {
    final budgetCubit = context.read<BudgetCubit>();
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: budgetCubit, child: const BudgetScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wireframe: Personal Finance Tracker'),
        actions: [
          IconButton(
            onPressed: _navigateToBudgets,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Monthly budgets',
          ),
        ],
      ),
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
                    ?._confirmDeleteExpense(expense.id),
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
