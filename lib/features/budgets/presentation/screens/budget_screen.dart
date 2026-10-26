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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54),
            child: Container(
              height: 40,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDAD3C3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(1),
                indicator: BoxDecoration(
                  color: Color(0xFF1C2437),
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
                labelColor: Color(0xFFF6F3EC),
                unselectedLabelColor: Color(0xFF1C2437),
                labelStyle: TextStyle(fontSize: 12),
                tabs: [
                  Tab(text: 'Categories'),
                  Tab(text: 'Recurring rules'),
                ],
              ),
            ),
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
          child: Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
                itemCount: state.summaries.length,
                itemBuilder: (context, index) => BudgetCategoryRow(
                  summary: state.summaries[index],
                  onSetBudget: () => onEditBudget(index),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () => _chooseBudgetCategory(context),
                  heroTag: 'budget-add-category',
                  backgroundColor: const Color(0xFF1C2437),
                  foregroundColor: const Color(0xFFF6F3EC),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _chooseBudgetCategory(BuildContext context) async {
    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Choose a category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            for (var index = 0; index < state.summaries.length; index++)
              ListTile(
                leading: Text(state.summaries[index].category.emoji),
                title: Text(state.summaries[index].category.name),
                onTap: () => Navigator.of(context).pop(index),
              ),
          ],
        ),
      ),
    );
    if (selectedIndex != null) onEditBudget(selectedIndex);
  }
}
