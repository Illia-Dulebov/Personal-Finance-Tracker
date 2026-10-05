import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitialState extends ExpenseState {
  const ExpenseInitialState();
}

class ExpenseLoadingState extends ExpenseState {
  const ExpenseLoadingState();
}

class ExpenseLoadedState extends ExpenseState {
  final List<Expense> expenses;

  const ExpenseLoadedState(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class ExpenseEmptyState extends ExpenseState {
  const ExpenseEmptyState();
}

class ExpenseErrorState extends ExpenseState {
  final String message;

  const ExpenseErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
