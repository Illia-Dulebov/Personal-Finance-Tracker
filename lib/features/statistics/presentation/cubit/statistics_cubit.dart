import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../domain/entities/statistics_filter.dart';
import '../../domain/usecases/get_expense_statistics.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final GetExpenseStatisticsUseCase getExpenseStatisticsUseCase;
  StatisticsFilter _filter;

  StatisticsCubit({
    required this.getExpenseStatisticsUseCase,
    DateTime? initialDate,
  }) : _filter = StatisticsFilter.initial(initialDate),
       super(StatisticsLoadingState(StatisticsFilter.initial(initialDate)));

  Future<void> load() => _load();

  Future<void> refresh() => _load();

  Future<void> selectPeriod(StatisticsPeriod period, [DateTime? date]) async {
    if (period == StatisticsPeriod.custom) return;
    _filter = _filter.forPeriod(period, date);
    await _load();
  }

  Future<void> selectMonth(DateTime month) async {
    _filter = _filter.forPeriod(StatisticsPeriod.month, month);
    await _load();
  }

  Future<void> selectCustomRange(DateTime start, DateTime endInclusive) async {
    if (endInclusive.isBefore(start)) {
      throw ArgumentError('The end date must not be before the start date.');
    }
    _filter = _filter.withCustomRange(start, endInclusive);
    await _load();
  }

  Future<void> selectCategory(Category? category) async {
    _filter = _filter.withCategory(category);
    await _load();
  }

  Future<void> selectCurrency(CurrencyCode? currency) async {
    _filter = _filter.withCurrency(currency);
    await _load();
  }

  Future<void> _load() async {
    emit(StatisticsLoadingState(_filter));
    try {
      final statistics = await getExpenseStatisticsUseCase(_filter);
      emit(StatisticsLoadedState(_filter, statistics));
    } on Exception {
      emit(StatisticsErrorState(_filter));
    }
  }
}
