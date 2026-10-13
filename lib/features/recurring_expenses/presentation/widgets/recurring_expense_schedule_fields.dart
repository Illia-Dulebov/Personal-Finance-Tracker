import 'package:flutter/material.dart';

import '../../domain/entities/recurring_frequency.dart';

class RecurringExpenseScheduleFields extends StatelessWidget {
  final RecurringFrequency frequency;
  final int scheduleDay;
  final ValueChanged<RecurringFrequency> onFrequencyChanged;
  final ValueChanged<int> onScheduleDayChanged;

  const RecurringExpenseScheduleFields({
    super.key,
    required this.frequency,
    required this.scheduleDay,
    required this.onFrequencyChanged,
    required this.onScheduleDayChanged,
  });

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<RecurringFrequency>(
          initialValue: frequency,
          decoration: const InputDecoration(labelText: 'Repeat'),
          items: RecurringFrequency.values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(_frequencyLabel(item)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onFrequencyChanged(value);
          },
        ),
        if (frequency != RecurringFrequency.daily)
          DropdownButtonFormField<int>(
            key: ValueKey(frequency),
            initialValue: scheduleDay,
            decoration: InputDecoration(
              labelText: frequency == RecurringFrequency.weekly
                  ? 'Day of week'
                  : 'Day of month',
            ),
            items: _scheduleDays
                .map(
                  (day) => DropdownMenuItem(
                    value: day,
                    child: Text(
                      frequency == RecurringFrequency.weekly
                          ? _weekdays[day - 1]
                          : '$day',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onScheduleDayChanged(value);
            },
          ),
      ],
    );
  }

  List<int> get _scheduleDays => frequency == RecurringFrequency.weekly
      ? List<int>.generate(7, (index) => index + 1)
      : List<int>.generate(31, (index) => index + 1);

  static String _frequencyLabel(RecurringFrequency value) => switch (value) {
    RecurringFrequency.daily => 'Daily',
    RecurringFrequency.weekly => 'Weekly',
    RecurringFrequency.monthly => 'Monthly',
  };
}
