import 'package:equatable/equatable.dart';
import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import '../../../currency/domain/entities/currency_code.dart';
import 'category.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final CurrencyCode currency;
  final DateTime date;
  final Category category;
  final PaymentMethod paymentMethod;
  final String description;
  final double? amountInBaseCurrency;
  final double? exchangeRateToBaseCurrency;
  final CurrencyCode? conversionBaseCurrency;
  final DateTime? conversionRateCapturedAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    required this.paymentMethod,
    required this.description,
    this.amountInBaseCurrency,
    this.exchangeRateToBaseCurrency,
    this.conversionBaseCurrency,
    this.conversionRateCapturedAt,
  });

  Expense copyWith({
    String? id,
    double? amount,
    CurrencyCode? currency,
    DateTime? date,
    Category? category,
    PaymentMethod? paymentMethod,
    String? description,
    double? amountInBaseCurrency,
    double? exchangeRateToBaseCurrency,
    CurrencyCode? conversionBaseCurrency,
    DateTime? conversionRateCapturedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      amountInBaseCurrency: amountInBaseCurrency ?? this.amountInBaseCurrency,
      exchangeRateToBaseCurrency:
          exchangeRateToBaseCurrency ?? this.exchangeRateToBaseCurrency,
      conversionBaseCurrency:
          conversionBaseCurrency ?? this.conversionBaseCurrency,
      conversionRateCapturedAt:
          conversionRateCapturedAt ?? this.conversionRateCapturedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    currency,
    date,
    category,
    paymentMethod,
    description,
    amountInBaseCurrency,
    exchangeRateToBaseCurrency,
    conversionBaseCurrency,
    conversionRateCapturedAt,
  ];
}
