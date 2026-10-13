import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recurring_expense_rule.dart';
import '../cubit/recurring_expense_cubit.dart';
import '../cubit/recurring_expense_state.dart';
import '../widgets/recurring_expense_empty_state.dart';
import '../widgets/recurring_expense_rule_card.dart';
import '../widgets/recurring_expense_rule_form_dialog.dart';

class RecurringExpenseRulesScreen extends StatefulWidget {
  const RecurringExpenseRulesScreen({super.key});

  @override
  State<RecurringExpenseRulesScreen> createState() =>
      _RecurringExpenseRulesScreenState();
}

class _RecurringExpenseRulesScreenState
    extends State<RecurringExpenseRulesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecurringExpenseCubit>().load();
  }

  Future<void> _editRule([RecurringExpenseRule? rule]) async {
    final result = await showDialog<RecurringExpenseRule>(
      context: context,
      builder: (_) => RecurringExpenseRuleFormDialog(rule: rule),
    );
    if (result != null && mounted) {
      await context.read<RecurringExpenseCubit>().save(result);
    }
  }

  Future<void> _deleteRule(RecurringExpenseRule rule) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete recurring rule?'),
        content: const Text(
          'Future expenses will no longer be generated. Existing expenses will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      await context.read<RecurringExpenseCubit>().delete(rule.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecurringExpenseCubit, RecurringExpenseState>(
      listener: (context, state) {
        if (state is RecurringExpenseErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) => switch (state) {
        RecurringExpenseInitialState() || RecurringExpenseLoadingState() =>
          const Center(child: CircularProgressIndicator()),
        RecurringExpenseErrorState(message: final message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              TextButton(
                onPressed: () => context.read<RecurringExpenseCubit>().load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        RecurringExpenseLoadedState(rules: final rules) => _RulesList(
          rules: rules,
          onAdd: () => _editRule(),
          onEdit: _editRule,
          onDelete: _deleteRule,
        ),
      },
    );
  }
}

class _RulesList extends StatelessWidget {
  final List<RecurringExpenseRule> rules;
  final VoidCallback onAdd;
  final ValueChanged<RecurringExpenseRule> onEdit;
  final ValueChanged<RecurringExpenseRule> onDelete;

  const _RulesList({
    required this.rules,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return RecurringExpenseEmptyState(onAdd: onAdd);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add recurring expense'),
          ),
        ),
        for (final rule in rules)
          RecurringExpenseRuleCard(
            rule: rule,
            onEdit: () => onEdit(rule),
            onDelete: () => onDelete(rule),
          ),
      ],
    );
  }
}
