import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/budget_cubit.dart';
import '../cubit/budget_state.dart';
import '../widgets/budget_category_row.dart';
import '../widgets/budget_month_selector.dart';
import '../widgets/monthly_budget_summary_card.dart';
import '../widgets/monthly_budget_form_dialog.dart';
import '../../../recurring_expenses/presentation/screens/recurring_expense_rules_screen.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budget'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Monthly budgets'),
              Tab(text: 'Recurring expenses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) => switch (state) {
                BudgetInitialState() || BudgetLoadingState() => const Center(
                  child: CircularProgressIndicator(),
                ),
                BudgetErrorState(message: final message) => Center(
                  child: Text(message),
                ),
                BudgetLoadedState() => _BudgetOverview(
                  state: state,
                  onPreviousMonth: () =>
                      context.read<BudgetCubit>().selectMonth(
                        DateTime(state.month.year, state.month.month - 1),
                      ),
                  onNextMonth: () => context.read<BudgetCubit>().selectMonth(
                    DateTime(state.month.year, state.month.month + 1),
                  ),
                  onEditBudget: (index) => _editBudget(context, state, index),
                ),
              },
            ),
            const RecurringExpenseRulesScreen(),
          ],
        ),
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
        MonthlyBudgetSummaryCard(totalBudgetAmount: state.totalBudgetAmount),
        BudgetMonthSelector(
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
