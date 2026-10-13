import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/recurring_expense_rule.dart';
import '../../domain/entities/recurring_frequency.dart';

class RecurringExpenseRuleCard extends StatelessWidget {
  final RecurringExpenseRule rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecurringExpenseRuleCard({
    super.key,
    required this.rule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(rule.category.emoji)),
        title: Text(
          rule.description.isEmpty ? rule.category.name : rule.description,
        ),
        subtitle: Text(
          '${rule.amount.toStringAsFixed(2)} ${rule.currency.value} · '
          '$_frequencyDescription · '
          'Next: ${DateFormat.yMMMd().format(rule.nextGenerationDate)}',
        ),
        isThreeLine: true,
        onTap: onEdit,
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') onEdit();
            if (action == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  String get _frequencyDescription => switch (rule.frequency) {
    RecurringFrequency.daily => 'Daily',
    RecurringFrequency.weekly => 'Weekly on ${_weekday(rule.scheduleDay!)}',
    RecurringFrequency.monthly =>
      'Monthly on day ${rule.scheduleDay} (clamped to month end)',
  };

  String _weekday(int weekday) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}
