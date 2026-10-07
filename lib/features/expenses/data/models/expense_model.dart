import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.amount,
    required super.currency,
    required super.date,
    required super.category,
    required super.paymentMethod,
    required super.description,
    super.amountInBaseCurrency,
    super.exchangeRateToBaseCurrency,
    super.conversionBaseCurrency,
    super.conversionRateCapturedAt,
  });

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      currency: expense.currency,
      date: expense.date,
      category: expense.category,
      paymentMethod: expense.paymentMethod,
      description: expense.description,
      amountInBaseCurrency: expense.amountInBaseCurrency,
      exchangeRateToBaseCurrency: expense.exchangeRateToBaseCurrency,
      conversionBaseCurrency: expense.conversionBaseCurrency,
      conversionRateCapturedAt: expense.conversionRateCapturedAt,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num).toDouble();
    final currency = CurrencyCode.fromValue(json['currency'] as String);
    final legacyBaseCurrencyExpense =
        currency == CurrencyCode.all &&
        json['amountInBaseCurrency'] == null &&
        json['exchangeRateToBaseCurrency'] == null;

    return ExpenseModel(
      id: json['id'] as String,
      amount: amount,
      currency: currency,
      date: DateTime.parse(json['date'] as String),
      category: Category(
        id: json['category']['id'] as String,
        name: json['category']['name'] as String,
        emoji: json['category']['emoji'] as String,
      ),
      paymentMethod: PaymentMethod.fromString(json['paymentMethod'] as String),
      description: json['description'] as String,
      amountInBaseCurrency:
          (json['amountInBaseCurrency'] as num?)?.toDouble() ??
          (legacyBaseCurrencyExpense ? amount : null),
      exchangeRateToBaseCurrency:
          (json['exchangeRateToBaseCurrency'] as num?)?.toDouble() ??
          (legacyBaseCurrencyExpense ? 1.0 : null),
      conversionBaseCurrency: json['conversionBaseCurrency'] == null
          ? (legacyBaseCurrencyExpense ? CurrencyCode.all : null)
          : CurrencyCode.fromValue(json['conversionBaseCurrency'] as String),
      conversionRateCapturedAt: json['conversionRateCapturedAt'] == null
          ? null
          : DateTime.parse(json['conversionRateCapturedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency.value,
      'date': date.toIso8601String(),
      'category': {
        'id': category.id,
        'name': category.name,
        'emoji': category.emoji,
      },
      'paymentMethod': paymentMethod.name,
      'description': description,
      'amountInBaseCurrency': amountInBaseCurrency,
      'exchangeRateToBaseCurrency': exchangeRateToBaseCurrency,
      'conversionBaseCurrency': conversionBaseCurrency?.value,
      'conversionRateCapturedAt': conversionRateCapturedAt?.toIso8601String(),
    };
  }

  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      currency: currency,
      date: date,
      category: category,
      paymentMethod: paymentMethod,
      description: description,
      amountInBaseCurrency: amountInBaseCurrency,
      exchangeRateToBaseCurrency: exchangeRateToBaseCurrency,
      conversionBaseCurrency: conversionBaseCurrency,
      conversionRateCapturedAt: conversionRateCapturedAt,
    );
  }
}
