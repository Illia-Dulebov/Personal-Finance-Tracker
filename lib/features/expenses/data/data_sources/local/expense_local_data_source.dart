import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/expense_model.dart';

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> saveExpenses(List<ExpenseModel> expenses);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  static const String cachedExpensesKey = 'CACHED_EXPENSES';
  final SharedPreferences prefs;

  ExpenseLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final jsonString = prefs.getString(cachedExpensesKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedJson = jsonDecode(jsonString);
        return decodedJson
            .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw CacheException('Failed to load expenses from cache: $e');
    }
  }

  @override
  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          expenses.map((e) => e.toJson()).toList();
      await prefs.setString(cachedExpensesKey, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException('Failed to save expenses to cache: $e');
    }
  }
}
