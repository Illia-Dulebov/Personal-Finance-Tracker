import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<void> call(Expense expense) async {
    if (!expense.amount.isFinite || expense.amount <= 0) {
      throw ArgumentError.value(
        expense.amount,
        'amount',
        'Must be a finite positive amount',
      );
    }

    final expenses = await repository.getExpenses();
    final existingIndex = expenses.indexWhere((item) => item.id == expense.id);
    if (existingIndex == -1) {
      throw StateError('Cannot update an expense that does not exist.');
    }
    final existing = expenses[existingIndex];
    if (expense.currency != existing.currency) {
      throw StateError('An expense currency cannot be changed after creation.');
    }

    final rate = existing.exchangeRateToBaseCurrency;
    if (rate != null && (!rate.isFinite || rate <= 0)) {
      throw StateError('The stored exchange rate is invalid.');
    }
    final amountInBaseCurrency = rate == null ? null : expense.amount * rate;
    if (amountInBaseCurrency != null && !amountInBaseCurrency.isFinite) {
      throw StateError(
        'The stored exchange rate produced an invalid converted amount.',
      );
    }
    final updatedExpense = Expense(
      id: expense.id,
      amount: expense.amount,
      currency: existing.currency,
      date: expense.date,
      category: expense.category,
      paymentMethod: expense.paymentMethod,
      description: expense.description,
      amountInBaseCurrency: amountInBaseCurrency,
      exchangeRateToBaseCurrency: rate,
      conversionBaseCurrency: existing.conversionBaseCurrency,
      conversionRateCapturedAt: existing.conversionRateCapturedAt,
    );

    return repository.updateExpense(updatedExpense);
  }
}
