import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_ui_tokens.dart';
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

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 38,
        horizontalTitleGap: 12,
        minVerticalPadding: 14,
        onTap: onTap,
        leading: CircleAvatar(
          radius: 19,
          backgroundColor: AppTheme.paperSecondary,
          child: Text(
            expense.category.emoji,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        title: Text(
          expense.description.isNotEmpty
              ? expense.description
              : expense.category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${expense.category.name} · ${expense.paymentMethod.label} · $formattedDate',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '−${expense.amount.toStringAsFixed(2)} ${expense.currency.value}',
              style: AppTextStyles.amountSmall.copyWith(
                color: AppTheme.rust,
                fontSize: 16,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 32, height: 36),
              padding: EdgeInsets.zero,
              tooltip: 'Delete expense',
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.muted,
                size: 18,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
