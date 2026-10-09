import 'package:equatable/equatable.dart';

import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/category.dart';

enum StatisticsPeriod { today, thisWeek, thisMonth, month, custom }

class StatisticsFilter extends Equatable {
  final StatisticsPeriod period;
  final DateTime startDate;
  final DateTime endDateExclusive;
  final String? categoryId;
  final CurrencyCode? currency;

  const StatisticsFilter({
    required this.period,
    required this.startDate,
    required this.endDateExclusive,
    this.categoryId,
    this.currency,
  });

  factory StatisticsFilter.initial([DateTime? date]) {
    final now = date ?? DateTime.now();
    return StatisticsFilter(
      period: StatisticsPeriod.thisMonth,
      startDate: DateTime(now.year, now.month),
      endDateExclusive: DateTime(now.year, now.month + 1),
    );
  }

  StatisticsFilter forPeriod(StatisticsPeriod newPeriod, [DateTime? date]) {
    final anchor = date ?? DateTime.now();
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    switch (newPeriod) {
      case StatisticsPeriod.today:
        return _withRange(
          newPeriod,
          day,
          DateTime(day.year, day.month, day.day + 1),
        );
      case StatisticsPeriod.thisWeek:
        final start = DateTime(day.year, day.month, day.day - day.weekday + 1);
        return _withRange(
          newPeriod,
          start,
          DateTime(start.year, start.month, start.day + 7),
        );
      case StatisticsPeriod.thisMonth:
      case StatisticsPeriod.month:
        final start = DateTime(anchor.year, anchor.month);
        return _withRange(
          newPeriod,
          start,
          DateTime(anchor.year, anchor.month + 1),
        );
      case StatisticsPeriod.custom:
        return this;
    }
  }

  StatisticsFilter withCustomRange(DateTime start, DateTime endInclusive) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(
      endInclusive.year,
      endInclusive.month,
      endInclusive.day,
    );
    return _withRange(
      StatisticsPeriod.custom,
      startDay,
      DateTime(endDay.year, endDay.month, endDay.day + 1),
    );
  }

  StatisticsFilter withCategory(Category? category) => StatisticsFilter(
    period: period,
    startDate: startDate,
    endDateExclusive: endDateExclusive,
    categoryId: category?.id,
    currency: currency,
  );

  StatisticsFilter withCurrency(CurrencyCode? value) => StatisticsFilter(
    period: period,
    startDate: startDate,
    endDateExclusive: endDateExclusive,
    categoryId: categoryId,
    currency: value,
  );

  StatisticsFilter _withRange(
    StatisticsPeriod value,
    DateTime start,
    DateTime endExclusive,
  ) => StatisticsFilter(
    period: value,
    startDate: start,
    endDateExclusive: endExclusive,
    categoryId: categoryId,
    currency: currency,
  );

  @override
  List<Object?> get props => [
    period,
    startDate,
    endDateExclusive,
    categoryId,
    currency,
  ];
}
