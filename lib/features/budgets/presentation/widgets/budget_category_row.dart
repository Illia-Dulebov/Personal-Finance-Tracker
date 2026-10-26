import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_ui_tokens.dart';
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
    final progress = budgetAmount == null || budgetAmount <= 0
        ? (summary.spending > 0 ? 1.0 : 0.0)
        : (summary.spending / budgetAmount).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${summary.category.emoji} ${summary.category.name}',
                  style: AppTextStyles.fieldValue.copyWith(fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: onSetBudget,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.muted,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  textStyle: AppTextStyles.caption,
                ),
                child: Text(
                  budgetAmount == null ? 'Set budget' : 'Edit budget',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                budgetAmount == null
                    ? '${summary.spending.toStringAsFixed(2)} ALL'
                    : '${summary.spending.toStringAsFixed(2)} / '
                          '${budgetAmount.toStringAsFixed(2)} ALL',
                style: AppTextStyles.amountSmall.copyWith(
                  color: summary.isOverBudget
                      ? AppTheme.rust
                      : AppTextStyles.amountSmall.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.paperSecondary,
              valueColor: AlwaysStoppedAnimation(
                summary.isOverBudget ? AppTheme.rust : AppTheme.sage,
              ),
            ),
          ),
          if (budgetAmount == null)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No budget set for this category',
                  style: TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  summary.isOverBudget
                      ? 'Over budget by ${(-remainingAmount!).toStringAsFixed(2)} ALL'
                      : 'Remaining: ${remainingAmount!.toStringAsFixed(2)} ALL',
                  style: TextStyle(
                    color: summary.isOverBudget
                        ? AppTheme.rust
                        : AppTheme.muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xs + 3),
          const Divider(height: 1, color: AppTheme.line),
        ],
      ),
    );
  }
}
