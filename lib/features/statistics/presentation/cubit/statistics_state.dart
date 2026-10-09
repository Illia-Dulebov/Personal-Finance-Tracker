import 'package:equatable/equatable.dart';

import '../../domain/entities/expense_statistics.dart';
import '../../domain/entities/statistics_filter.dart';

sealed class StatisticsState extends Equatable {
  final StatisticsFilter filter;

  const StatisticsState(this.filter);

  @override
  List<Object?> get props => [filter];
}

class StatisticsLoadingState extends StatisticsState {
  const StatisticsLoadingState(super.filter);
}

class StatisticsLoadedState extends StatisticsState {
  final ExpenseStatistics statistics;

  const StatisticsLoadedState(super.filter, this.statistics);

  @override
  List<Object?> get props => [filter, statistics];
}

class StatisticsErrorState extends StatisticsState {
  const StatisticsErrorState(super.filter);
}
