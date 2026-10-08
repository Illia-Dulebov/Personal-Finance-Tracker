import '../../../expenses/domain/entities/category.dart';
import '../../domain/entities/monthly_budget.dart';

class MonthlyBudgetModel extends MonthlyBudget {
  MonthlyBudgetModel({
    required super.category,
    required super.month,
    required super.amount,
  });

  factory MonthlyBudgetModel.fromEntity(MonthlyBudget budget) {
    return MonthlyBudgetModel(
      category: budget.category,
      month: budget.month,
      amount: budget.amount,
    );
  }

  factory MonthlyBudgetModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>;
    return MonthlyBudgetModel(
      category: Category(
        id: category['id'] as String,
        name: category['name'] as String,
        emoji: category['emoji'] as String,
      ),
      month: DateTime.parse(json['month'] as String),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'category': {
      'id': category.id,
      'name': category.name,
      'emoji': category.emoji,
    },
    'month': month.toIso8601String(),
    'amount': amount,
  };

  MonthlyBudget toEntity() =>
      MonthlyBudget(category: category, month: month, amount: amount);
}
