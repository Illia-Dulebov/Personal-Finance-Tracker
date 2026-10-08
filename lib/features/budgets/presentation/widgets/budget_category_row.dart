import 'package:flutter/material.dart';

import '../../domain/entities/budget_category_summary.dart';

class BudgetCategoryRow extends StatelessWidget {
  final BudgetCategorySummary summary;
  final VoidCallback onSetBudget;

  const BudgetCategoryRow({
    required this.summary,
    required this.onSetBudget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final budgetAmount = summary.budgetAmount;
    final remainingAmount = summary.remainingAmount;
    final amountColor = summary.isOverBudget
        ? Theme.of(context).colorScheme.error
        : null;

    return Card(
      child: ListTile(
        leading: Text(summary.category.emoji),
        title: Text(summary.category.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spent: ${summary.spending.toStringAsFixed(2)} ALL'),
            if (budgetAmount != null) ...[
              Text('Budget: ${budgetAmount.toStringAsFixed(2)} ALL'),
              Text(
                summary.isOverBudget
                    ? 'Over budget by ${(-remainingAmount!).toStringAsFixed(2)} ALL'
                    : 'Remaining: ${remainingAmount!.toStringAsFixed(2)} ALL',
                style: TextStyle(color: amountColor),
              ),
            ] else if (summary.spending > 0)
              const Text('No limit configured'),
          ],
        ),
        trailing: TextButton(
          onPressed: onSetBudget,
          child: Text(budgetAmount == null ? 'Set budget' : 'Edit budget'),
        ),
      ),
    );
  }
}
