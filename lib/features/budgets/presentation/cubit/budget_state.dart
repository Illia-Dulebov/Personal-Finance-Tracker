import 'package:equatable/equatable.dart';

import '../../domain/entities/budget_category_summary.dart';

sealed class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitialState extends BudgetState {
  const BudgetInitialState();
}

class BudgetLoadingState extends BudgetState {
  const BudgetLoadingState();
}

class BudgetLoadedState extends BudgetState {
  final DateTime month;
  final List<BudgetCategorySummary> summaries;

  const BudgetLoadedState({required this.month, required this.summaries});

  @override
  List<Object?> get props => [month, summaries];
}

class BudgetErrorState extends BudgetState {
  final String message;

  const BudgetErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
