import '../../../currency/domain/entities/currency_code.dart';
import '../entities/expense.dart';

double? amountInAll(Expense expense) {
  if (expense.conversionBaseCurrency == CurrencyCode.all) {
    return expense.amountInBaseCurrency ??
        (expense.currency == CurrencyCode.all ? expense.amount : null);
  }
  if (expense.currency == CurrencyCode.all &&
      expense.conversionBaseCurrency == null) {
    return expense.amountInBaseCurrency ?? expense.amount;
  }
  return null;
}
