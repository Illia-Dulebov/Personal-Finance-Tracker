import 'package:equatable/equatable.dart';

import '../../domain/entities/recurring_expense_rule.dart';

sealed class RecurringExpenseState extends Equatable {
  const RecurringExpenseState();

  @override
  List<Object?> get props => [];
}

class RecurringExpenseInitialState extends RecurringExpenseState {
  const RecurringExpenseInitialState();
}

class RecurringExpenseLoadingState extends RecurringExpenseState {
  const RecurringExpenseLoadingState();
}

class RecurringExpenseLoadedState extends RecurringExpenseState {
  final List<RecurringExpenseRule> rules;

  const RecurringExpenseLoadedState(this.rules);

  @override
  List<Object?> get props => [rules];
}

class RecurringExpenseErrorState extends RecurringExpenseState {
  final String message;

  const RecurringExpenseErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
