import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/monthly_budget.dart';
import '../../domain/usecases/get_monthly_budget_overview.dart';
import '../../domain/usecases/save_monthly_budget.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final GetMonthlyBudgetOverviewUseCase getMonthlyBudgetOverviewUseCase;
  final SaveMonthlyBudgetUseCase saveMonthlyBudgetUseCase;
  DateTime _selectedMonth;

  BudgetCubit({
    required this.getMonthlyBudgetOverviewUseCase,
    required this.saveMonthlyBudgetUseCase,
    DateTime? initialMonth,
  }) : _selectedMonth = _monthStart(initialMonth ?? DateTime.now()),
       super(const BudgetInitialState());

  Future<void> load() => _load(_selectedMonth);

  Future<void> refresh() => _load(_selectedMonth);

  Future<void> selectMonth(DateTime month) {
    _selectedMonth = _monthStart(month);
    return _load(_selectedMonth);
  }

  Future<void> saveBudget(MonthlyBudget budget) async {
    try {
      await saveMonthlyBudgetUseCase(budget);
      await _load(_selectedMonth);
    } on Exception {
      emit(const BudgetErrorState('Unable to save the budget.'));
    }
  }

  Future<void> _load(DateTime month) async {
    emit(const BudgetLoadingState());
    try {
      final summaries = await getMonthlyBudgetOverviewUseCase(month);
      final totalBudgetAmount = summaries.fold<double>(
        0,
        (total, summary) => total + (summary.budgetAmount ?? 0),
      );
      emit(
        BudgetLoadedState(
          month: month,
          summaries: summaries,
          totalBudgetAmount: totalBudgetAmount,
        ),
      );
    } on Exception {
      emit(const BudgetErrorState('Unable to load budget information.'));
    }
  }

  static DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);
}
