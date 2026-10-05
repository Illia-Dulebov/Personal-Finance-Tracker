import 'package:personal_finance_tracker/core/constants/app_constants.dart';
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
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: DateTime.parse(json['date'] as String),
      category: Category(
        id: json['category']['id'] as String,
        name: json['category']['name'] as String,
        emoji: json['category']['emoji'] as String,
      ),
      paymentMethod: PaymentMethod.fromString(json['paymentMethod'] as String),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'category': {
        'id': category.id,
        'name': category.name,
        'emoji': category.emoji,
      },
      'paymentMethod': paymentMethod.name,
      'description': description,
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
    );
  }
}
