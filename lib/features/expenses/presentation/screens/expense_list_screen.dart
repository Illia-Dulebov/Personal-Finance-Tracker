import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../budgets/presentation/cubit/budget_cubit.dart';
import '../../domain/entities/expense.dart';
import '../../domain/utils/expense_amount_converter.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/delete_expense_confirmation_dialog.dart';
import '../widgets/expense_item_card.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  bool _showAllExpenses = false;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseCubit>().loadExpenses();
  }

  Future<void> _navigateToAddExpense() async {
    final newExpense = await context.push<Expense>('/expense/add');

    if (newExpense != null && mounted) {
      await context.read<ExpenseCubit>().addExpense(newExpense);
      await _refreshBudget();
    }
  }

  Future<void> _navigateToEditExpense(Expense expense) async {
    final updatedExpense = await context.push<Expense>(
      '/expense/edit',
      extra: expense,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          final now = DateTime.now();
          return switch (state) {
            ExpenseInitialState() || ExpenseLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
            ExpenseErrorState(message: final message) => Center(
              child: Text(message),
            ),
            ExpenseEmptyState() => _HomeExpenseList(
              expenses: const [],
              monthlyTotal: 0,
              month: now,
              showAll: false,
              onToggleAll: () {},
              onTap: _navigateToEditExpense,
              onDelete: _confirmDeleteExpense,
            ),
            ExpenseLoadedState(expenses: final expenses) => _HomeExpenseList(
              expenses: expenses,
              monthlyTotal: _monthlyTotal(expenses, now),
              month: now,
              showAll: _showAllExpenses,
              onToggleAll: () =>
                  setState(() => _showAllExpenses = !_showAllExpenses),
              onTap: _navigateToEditExpense,
              onDelete: _confirmDeleteExpense,
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  double _monthlyTotal(List<Expense> expenses, DateTime now) {
    final monthStart = DateTime(now.year, now.month);
    final nextMonthStart = DateTime(now.year, now.month + 1);
    var total = 0.0;

    for (final expense in expenses) {
      if (expense.date.isBefore(monthStart) ||
          !expense.date.isBefore(nextMonthStart)) {
        continue;
      }
      total += amountInAll(expense) ?? 0;
    }

    return total;
  }
}

class _HomeExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final double monthlyTotal;
  final DateTime month;
  final bool showAll;
  final VoidCallback onToggleAll;
  final ValueChanged<Expense> onTap;
  final ValueChanged<String> onDelete;

  const _HomeExpenseList({
    required this.expenses,
    required this.monthlyTotal,
    required this.month,
    required this.showAll,
    required this.onToggleAll,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visibleExpenseCount = showAll
        ? expenses.length
        : expenses.length.clamp(0, 6).toInt();
    final itemCount = expenses.isEmpty ? 3 : visibleExpenseCount + 2;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _MonthlyExpenseSummaryCard(month: month, total: monthlyTotal);
        }
        if (index == 1) {
          return _ExpenseListHeader(
            expenseCount: expenses.length,
            showAll: showAll,
            onToggleAll: onToggleAll,
          );
        }
        if (expenses.isEmpty) {
          return const _EmptyExpenseState();
        }

        final expense = expenses[index - 2];
        return ExpenseItemCard(
          expense: expense,
          onTap: () => onTap(expense),
          onDelete: () => onDelete(expense.id),
        );
      },
    );
  }
}

class _MonthlyExpenseSummaryCard extends StatelessWidget {
  final DateTime month;
  final double total;

  const _MonthlyExpenseSummaryCard({required this.month, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      color: AppTheme.paperSecondary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('MMMM yyyy').format(month)} · spent so far',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 4),
            Text(
              '${total.toStringAsFixed(2)} ALL',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListHeader extends StatelessWidget {
  final int expenseCount;
  final bool showAll;
  final VoidCallback onToggleAll;

  const _ExpenseListHeader({
    required this.expenseCount,
    required this.showAll,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Recent expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (expenseCount > 6)
            TextButton(
              onPressed: onToggleAll,
              child: Text(showAll ? 'Show recent' : 'View all'),
            ),
        ],
      ),
    );
  }
}

class _EmptyExpenseState extends StatelessWidget {
  const _EmptyExpenseState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text('No expenses recorded yet.')),
    );
  }
}
