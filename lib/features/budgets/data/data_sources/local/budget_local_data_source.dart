import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/monthly_budget_model.dart';

class BudgetLocalDataSource {
  static const String cachedBudgetsKey = 'CACHED_MONTHLY_BUDGETS';

  final SharedPreferences prefs;

  BudgetLocalDataSource({required this.prefs});

  Future<List<MonthlyBudgetModel>> getBudgets() async {
    final jsonString = prefs.getString(cachedBudgetsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map(
          (item) => MonthlyBudgetModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveBudgets(List<MonthlyBudgetModel> budgets) async {
    await prefs.setString(
      cachedBudgetsKey,
      jsonEncode(budgets.map((budget) => budget.toJson()).toList()),
    );
  }
}
