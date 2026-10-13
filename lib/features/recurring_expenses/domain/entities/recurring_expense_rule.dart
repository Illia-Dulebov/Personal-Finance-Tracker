import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/category.dart';
import 'recurring_frequency.dart';

class RecurringExpenseRule extends Equatable {
  final String id;
  final double amount;
  final CurrencyCode currency;
  final Category category;
  final PaymentMethod paymentMethod;
  final String description;
  final RecurringFrequency frequency;
  final int? scheduleDay;
  final DateTime? lastGeneratedDate;
  final DateTime nextGenerationDate;

  const RecurringExpenseRule({
    required this.id,
    required this.amount,
    required this.currency,
    required this.category,
    required this.paymentMethod,
    required this.description,
    required this.frequency,
    required this.scheduleDay,
    required this.lastGeneratedDate,
    required this.nextGenerationDate,
  });

  RecurringExpenseRule copyWith({
    double? amount,
    CurrencyCode? currency,
    Category? category,
    PaymentMethod? paymentMethod,
    String? description,
    RecurringFrequency? frequency,
    int? scheduleDay,
    DateTime? lastGeneratedDate,
    DateTime? nextGenerationDate,
  }) {
    return RecurringExpenseRule(
      id: id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      scheduleDay: scheduleDay ?? this.scheduleDay,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      nextGenerationDate: nextGenerationDate ?? this.nextGenerationDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    currency,
    category,
    paymentMethod,
    description,
    frequency,
    scheduleDay,
    lastGeneratedDate,
    nextGenerationDate,
  ];
}
