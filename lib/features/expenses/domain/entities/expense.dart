import 'package:equatable/equatable.dart';
import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'category.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final Category category;
  final PaymentMethod paymentMethod;
  final String description;

  const Expense({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    required this.paymentMethod,
    required this.description,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? currency,
    DateTime? date,
    Category? category,
    PaymentMethod? paymentMethod,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
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
      ];
}
