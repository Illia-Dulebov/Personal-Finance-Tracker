import 'package:personal_finance_tracker/core/constants/app_constants.dart';

import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../domain/entities/recurring_expense_rule.dart';
import '../../domain/entities/recurring_frequency.dart';

class RecurringExpenseRuleModel extends RecurringExpenseRule {
  const RecurringExpenseRuleModel({
    required super.id,
    required super.amount,
    required super.currency,
    required super.category,
    required super.paymentMethod,
    required super.description,
    required super.frequency,
    required super.scheduleDay,
    required super.lastGeneratedDate,
    required super.nextGenerationDate,
  });

  factory RecurringExpenseRuleModel.fromEntity(RecurringExpenseRule rule) =>
      RecurringExpenseRuleModel(
        id: rule.id,
        amount: rule.amount,
        currency: rule.currency,
        category: rule.category,
        paymentMethod: rule.paymentMethod,
        description: rule.description,
        frequency: rule.frequency,
        scheduleDay: rule.scheduleDay,
        lastGeneratedDate: rule.lastGeneratedDate,
        nextGenerationDate: rule.nextGenerationDate,
      );

  factory RecurringExpenseRuleModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>;
    final categoryId = categoryJson['id'] as String;
    final category = AppConstants.defaultCategories.firstWhere(
      (item) => item.id == categoryId,
      orElse: () => Category(
        id: categoryId,
        name: categoryJson['name'] as String,
        emoji: categoryJson['emoji'] as String,
      ),
    );
    return RecurringExpenseRuleModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: CurrencyCode.fromValue(json['currency'] as String),
      category: category,
      paymentMethod: PaymentMethod.fromString(json['paymentMethod'] as String),
      description: json['description'] as String,
      frequency: RecurringFrequency.values.byName(json['frequency'] as String),
      scheduleDay: json['scheduleDay'] as int?,
      lastGeneratedDate: json['lastGeneratedDate'] == null
          ? null
          : DateTime.parse(json['lastGeneratedDate'] as String),
      nextGenerationDate: DateTime.parse(json['nextGenerationDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'currency': currency.value,
    'category': {
      'id': category.id,
      'name': category.name,
      'emoji': category.emoji,
    },
    'paymentMethod': paymentMethod.name,
    'description': description,
    'frequency': frequency.name,
    'scheduleDay': scheduleDay,
    'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
    'nextGenerationDate': nextGenerationDate.toIso8601String(),
  };
}
