import '../entities/recurring_expense_rule.dart';
import '../entities/recurring_frequency.dart';

class RecurrenceSchedule {
  static DateTime firstOccurrenceOnOrAfter(
    RecurringFrequency frequency,
    int? scheduleDay,
    DateTime date,
  ) {
    final start = _dateOnly(date);
    return switch (frequency) {
      RecurringFrequency.daily => start,
      RecurringFrequency.weekly => start.add(
        Duration(days: ((scheduleDay! - start.weekday) + 7) % 7),
      ),
      RecurringFrequency.monthly => _monthlyOnOrAfter(scheduleDay!, start),
    };
  }

  static DateTime nextOccurrence(
    RecurringExpenseRule rule,
    DateTime occurrence,
  ) {
    final current = _dateOnly(occurrence);
    return switch (rule.frequency) {
      RecurringFrequency.daily => current.add(const Duration(days: 1)),
      RecurringFrequency.weekly => current.add(const Duration(days: 7)),
      RecurringFrequency.monthly => _monthlyAfter(rule.scheduleDay!, current),
    };
  }

  static DateTime _monthlyOnOrAfter(int day, DateTime start) {
    var month = DateTime(start.year, start.month);
    while (true) {
      final candidate = _clampedMonthDay(month.year, month.month, day);
      if (!candidate.isBefore(start)) return candidate;
      month = DateTime(month.year, month.month + 1);
    }
  }

  static DateTime _monthlyAfter(int day, DateTime current) {
    var month = DateTime(current.year, current.month + 1);
    while (true) {
      final candidate = _clampedMonthDay(month.year, month.month, day);
      if (candidate.isAfter(current)) return candidate;
      month = DateTime(month.year, month.month + 1);
    }
  }

  static DateTime _clampedMonthDay(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, lastDay));
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
