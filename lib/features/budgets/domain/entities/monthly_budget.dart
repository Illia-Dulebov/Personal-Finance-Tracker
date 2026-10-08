import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/category.dart';

class MonthlyBudget extends Equatable {
  final Category category;
  final DateTime month;
  final double amount;

  MonthlyBudget({
    required this.category,
    required DateTime month,
    required this.amount,
  }) : month = DateTime(month.year, month.month);

  @override
  List<Object?> get props => [category, month, amount];
}
