import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recurring_expense_rule.dart';
import '../../domain/repositories/recurring_expense_repository.dart';
import '../../domain/usecases/save_recurring_expense_rule.dart';
import 'recurring_expense_state.dart';

class RecurringExpenseCubit extends Cubit<RecurringExpenseState> {
  final RecurringExpenseRepository repository;
  final SaveRecurringExpenseRuleUseCase saveRuleUseCase;

  RecurringExpenseCubit({
    required this.repository,
    required this.saveRuleUseCase,
  }) : super(const RecurringExpenseInitialState());

  Future<void> load() async {
    emit(const RecurringExpenseLoadingState());
    try {
      emit(RecurringExpenseLoadedState(await repository.getRules()));
    } on Exception {
      emit(
        const RecurringExpenseErrorState('Unable to load recurring expenses.'),
      );
    }
  }

  Future<void> save(RecurringExpenseRule rule) async {
    try {
      await saveRuleUseCase(rule);
      emit(RecurringExpenseLoadedState(await repository.getRules()));
    } on Exception {
      emit(
        const RecurringExpenseErrorState(
          'Unable to save the recurring expense.',
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await repository.deleteRule(id);
      emit(RecurringExpenseLoadedState(await repository.getRules()));
    } on Exception {
      emit(
        const RecurringExpenseErrorState(
          'Unable to delete the recurring expense.',
        ),
      );
    }
  }
}
