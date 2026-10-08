import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../widgets/budget_category_row.dart';
import '../widgets/monthly_budget_form_dialog.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetCubit>().load();
  }

  Future<void> _editBudget(
    BuildContext context,
    BudgetLoadedState state,
    int index,
  ) async {
    final summary = state.summaries[index];
    final budget = await showDialog(
      context: context,
      builder: (_) =>
          MonthlyBudgetFormDialog(month: state.month, summary: summary),
    );
    if (budget != null && context.mounted) {
      await context.read<BudgetCubit>().saveBudget(budget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly budgets')),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) => switch (state) {
          BudgetInitialState() || BudgetLoadingState() => const Center(
            child: CircularProgressIndicator(),
          ),
          BudgetErrorState(message: final message) => Center(
            child: Text(message),
          ),
          BudgetLoadedState() => _BudgetOverview(
            state: state,
            onPreviousMonth: () => context.read<BudgetCubit>().selectMonth(
              DateTime(state.month.year, state.month.month - 1),
            ),
            onNextMonth: () => context.read<BudgetCubit>().selectMonth(
              DateTime(state.month.year, state.month.month + 1),
            ),
            onEditBudget: (index) => _editBudget(context, state, index),
          ),
        },
      ),
    );
  }
}

class _BudgetOverview extends StatelessWidget {
  final BudgetLoadedState state;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int> onEditBudget;

  const _BudgetOverview({
    required this.state,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Total budgets: ${state.totalBudgetAmount.toStringAsFixed(2)} ALL',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _MonthSelector(
          month: state.month,
          onPreviousMonth: onPreviousMonth,
          onNextMonth: onNextMonth,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.summaries.length,
            itemBuilder: (context, index) => BudgetCategoryRow(
              summary: state.summaries[index],
              onSetBudget: () => onEditBudget(index),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _MonthSelector({
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPreviousMonth,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
        ),
        Text(
          '${_monthNames[month.month - 1]} ${month.year}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: onNextMonth,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
        ),
      ],
    );
  }

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
