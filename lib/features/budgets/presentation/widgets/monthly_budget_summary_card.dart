import 'package:flutter/material.dart';

class MonthlyBudgetSummaryCard extends StatelessWidget {
  final double totalBudgetAmount;

  const MonthlyBudgetSummaryCard({super.key, required this.totalBudgetAmount});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total budgets: ${totalBudgetAmount.toStringAsFixed(2)} ALL',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Category limits for the selected month',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
