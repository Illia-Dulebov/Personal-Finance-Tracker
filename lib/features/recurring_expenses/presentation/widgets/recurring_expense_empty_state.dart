import 'package:flutter/material.dart';

class RecurringExpenseEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const RecurringExpenseEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No recurring expenses yet.'),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add recurring expense'),
          ),
        ],
      ),
    );
  }
}
