import '../../../expenses/domain/entities/expense.dart';

abstract class GeneratedExpenseStore {
  Future<bool> hasOccurrence(String occurrenceKey);
  Future<bool> saveGeneratedExpense(Expense expense, String occurrenceKey);
}
