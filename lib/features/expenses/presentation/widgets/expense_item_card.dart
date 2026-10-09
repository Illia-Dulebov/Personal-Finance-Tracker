import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/expense.dart';

class ExpenseItemCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseItemCard({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d').format(expense.date);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.paperSecondary,
          child: Text(
            expense.category.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          expense.description.isNotEmpty
              ? expense.description
              : expense.category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${expense.category.name} · ${expense.paymentMethod.label} · $formattedDate',
          style: const TextStyle(color: AppTheme.muted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${expense.amount.toStringAsFixed(2)} ${expense.currency.value}',
              style: const TextStyle(
                color: AppTheme.rust,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
