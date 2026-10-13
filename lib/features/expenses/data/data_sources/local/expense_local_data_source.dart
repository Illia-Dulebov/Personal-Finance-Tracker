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
  bool hasProcessedOccurrence(String occurrenceKey);
  Future<bool> saveGeneratedExpense(ExpenseModel expense, String occurrenceKey);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  static const String cachedExpensesKey = 'CACHED_EXPENSES';
  final SharedPreferences prefs;

  ExpenseLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      return _readState().expenses;
    } catch (e) {
      throw CacheException('Failed to load expenses from cache: $e');
    }
  }

  @override
  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    try {
      final processedOccurrences = _readState().processedOccurrences;
      await _writeState(expenses, processedOccurrences);
    } catch (e) {
      throw CacheException('Failed to save expenses to cache: $e');
    }
  }

  @override
  Future<bool> saveGeneratedExpense(
    ExpenseModel expense,
    String occurrenceKey,
  ) async {
    try {
      final state = _readState();
      if (state.processedOccurrences.contains(occurrenceKey)) return false;
      state.expenses.add(expense);
      state.processedOccurrences.add(occurrenceKey);
      await _writeState(state.expenses, state.processedOccurrences);
      return true;
    } catch (e) {
      throw CacheException('Failed to save generated expense: $e');
    }
  }

  @override
  bool hasProcessedOccurrence(String occurrenceKey) =>
      _readState().processedOccurrences.contains(occurrenceKey);

  _ExpenseCacheState _readState() {
    final jsonString = prefs.getString(cachedExpensesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return _ExpenseCacheState([], <String>{});
    }
    final decoded = jsonDecode(jsonString);
    if (decoded is List<dynamic>) {
      return _ExpenseCacheState(
        decoded
            .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        <String>{},
      );
    }
    final cache = decoded as Map<String, dynamic>;
    final expenses = (cache['expenses'] as List<dynamic>)
        .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final occurrences = (cache['processedOccurrences'] as List<dynamic>)
        .cast<String>()
        .toSet();
    return _ExpenseCacheState(expenses, occurrences);
  }

  Future<void> _writeState(
    List<ExpenseModel> expenses,
    Set<String> processedOccurrences,
  ) async {
    await prefs.setString(
      cachedExpensesKey,
      jsonEncode({
        'expenses': expenses.map((expense) => expense.toJson()).toList(),
        'processedOccurrences': processedOccurrences.toList(),
      }),
    );
  }
}

class _ExpenseCacheState {
  final List<ExpenseModel> expenses;
  final Set<String> processedOccurrences;

  _ExpenseCacheState(this.expenses, this.processedOccurrences);
}
