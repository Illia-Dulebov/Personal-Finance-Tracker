import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  ExpenseCubit({
    required this.getExpensesUseCase,
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(const ExpenseInitialState());

  Future<void> loadExpenses() async {
    emit(const ExpenseLoadingState());
    try {
      final expenses = await getExpensesUseCase();
      if (expenses.isEmpty) {
        emit(const ExpenseEmptyState());
      } else {
        emit(ExpenseLoadedState(expenses));
      }
    } catch (_) {
      emit(const ExpenseErrorState('Something went wrong.'));
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await createExpenseUseCase(expense);
      await loadExpenses();
    } catch (_) {
      emit(const ExpenseErrorState('Something went wrong.'));
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await updateExpenseUseCase(expense);
      await loadExpenses();
    } catch (_) {
      emit(const ExpenseErrorState('Something went wrong.'));
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await deleteExpenseUseCase(id);
      await loadExpenses();
    } catch (_) {
      emit(const ExpenseErrorState('Something went wrong.'));
    }
  }
}
