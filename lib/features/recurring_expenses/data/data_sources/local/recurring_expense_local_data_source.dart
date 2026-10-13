import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/recurring_expense_rule_model.dart';

class RecurringExpenseLocalDataSource {
  static const cachedRulesKey = 'CACHED_RECURRING_EXPENSE_RULES';
  final SharedPreferences prefs;

  RecurringExpenseLocalDataSource({required this.prefs});

  Future<List<RecurringExpenseRuleModel>> getRules() async {
    final jsonString = prefs.getString(cachedRulesKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map(
            (item) => RecurringExpenseRuleModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on Exception catch (error) {
      throw FormatException('Failed to load recurring rules: $error');
    }
  }

  Future<void> saveRules(List<RecurringExpenseRuleModel> rules) async {
    await prefs.setString(
      cachedRulesKey,
      jsonEncode(rules.map((rule) => rule.toJson()).toList()),
    );
  }
}
