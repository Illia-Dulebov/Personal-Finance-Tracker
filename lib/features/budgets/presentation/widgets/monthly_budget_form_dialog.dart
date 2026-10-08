import 'package:flutter/material.dart';

import '../../domain/entities/budget_category_summary.dart';
import '../../domain/entities/monthly_budget.dart';

class MonthlyBudgetFormDialog extends StatefulWidget {
  final DateTime month;
  final BudgetCategorySummary summary;

  const MonthlyBudgetFormDialog({
    required this.month,
    required this.summary,
    super.key,
  });

  @override
  State<MonthlyBudgetFormDialog> createState() =>
      _MonthlyBudgetFormDialogState();
}

class _MonthlyBudgetFormDialogState extends State<MonthlyBudgetFormDialog> {
  late final TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.summary.budgetAmount?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.summary.category.name} budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('For ${_monthLabel(widget.month)} in ALL'),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Monthly limit'),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || !amount.isFinite || amount <= 0) {
                  return 'Enter an amount greater than zero';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              MonthlyBudget(
                category: widget.summary.category,
                month: widget.month,
                amount: double.parse(_amountController.text.trim()),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _monthLabel(DateTime month) =>
      '${_monthNames[month.month - 1]} ${month.year}';

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
