import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../../currency/domain/repositories/currency_repository.dart';
import '../../../currency/domain/entities/currency_code.dart';

class CreateExpenseUseCase {
  final ExpenseRepository repository;
  final CurrencyRepository currencyRepository;

  CreateExpenseUseCase(this.repository, this.currencyRepository);

  Future<void> call(Expense expense) async {
    if (!expense.amount.isFinite || expense.amount <= 0) {
      throw ArgumentError.value(
        expense.amount,
        'amount',
        'Must be a finite positive amount',
      );
    }

    final quote = await currencyRepository.getRateToBaseCurrency(
      expense.currency,
    );
    final amountInBaseCurrency = expense.amount * quote.rate;
    if (!quote.rate.isFinite ||
        quote.rate <= 0 ||
        !amountInBaseCurrency.isFinite) {
      throw StateError(
        'The exchange rate produced an invalid converted amount.',
      );
    }

    final convertedExpense = Expense(
      id: expense.id,
      amount: expense.amount,
      currency: expense.currency,
      date: expense.date,
      category: expense.category,
      paymentMethod: expense.paymentMethod,
      description: expense.description,
      amountInBaseCurrency: amountInBaseCurrency,
      exchangeRateToBaseCurrency: quote.rate,
      conversionBaseCurrency: CurrencyCode.all,
      conversionRateCapturedAt: quote.capturedAt,
    );

    return repository.addExpense(convertedExpense);
  }
}
