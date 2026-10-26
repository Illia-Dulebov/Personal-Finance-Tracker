import 'package:flutter/material.dart';

class MonthlyBudgetSummaryCard extends StatelessWidget {
  final double totalBudgetAmount;

  const MonthlyBudgetSummaryCard({super.key, required this.totalBudgetAmount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Text(
            'Total budgets: ${totalBudgetAmount.toStringAsFixed(2)} ALL',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Category limits for the selected month',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8A8578)),
          ),
        ],
      ),
    );
  }
}
