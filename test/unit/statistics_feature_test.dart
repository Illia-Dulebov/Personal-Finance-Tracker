import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/category.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:personal_finance_tracker/features/statistics/domain/entities/statistics_filter.dart';
import 'package:personal_finance_tracker/features/statistics/domain/usecases/get_expense_statistics.dart';

class _FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> expenses;

  _FakeExpenseRepository(this.expenses);

  @override
  Future<List<Expense>> getExpenses() async => expenses;

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}
}

Expense _expense({
  required String id,
  required double amount,
  required CurrencyCode currency,
  required DateTime date,
  Category? category,
  double? amountInBaseCurrency,
  CurrencyCode? conversionBaseCurrency,
}) => Expense(
  id: id,
  amount: amount,
  currency: currency,
  date: date,
  category: category ?? AppConstants.defaultCategories.first,
  paymentMethod: PaymentMethod.cash,
  description: '',
  amountInBaseCurrency: amountInBaseCurrency,
  conversionBaseCurrency: conversionBaseCurrency,
);

void main() {
  final food = AppConstants.defaultCategories.firstWhere(
    (category) => category.id == 'food',
  );
  final transport = AppConstants.defaultCategories.firstWhere(
    (category) => category.id == 'transport',
  );

  group('Statistics period ranges', () {
    test('uses a Monday-start week', () {
      final filter = StatisticsFilter.initial(
        DateTime(2026, 10, 7),
      ).forPeriod(StatisticsPeriod.thisWeek, DateTime(2026, 10, 7));

      expect(filter.startDate, DateTime(2026, 10, 5));
      expect(filter.endDateExclusive, DateTime(2026, 10, 12));
    });

    test('includes both full days in a custom range', () {
      final filter = StatisticsFilter.initial().withCustomRange(
        DateTime(2026, 10, 3, 18),
        DateTime(2026, 10, 5, 7),
      );

      expect(filter.startDate, DateTime(2026, 10, 3));
      expect(filter.endDateExclusive, DateTime(2026, 10, 6));
    });
  });

  group('GetExpenseStatisticsUseCase', () {
    test(
      'aggregates ALL totals with saved conversion and original currency',
      () async {
        final expenses = [
          _expense(
            id: 'all',
            amount: 100,
            currency: CurrencyCode.all,
            date: DateTime(2026, 3, 2),
            category: food,
          ),
          _expense(
            id: 'eur',
            amount: 10,
            currency: CurrencyCode.eur,
            date: DateTime(2026, 3, 12),
            category: food,
            amountInBaseCurrency: 1200,
            conversionBaseCurrency: CurrencyCode.all,
          ),
          _expense(
            id: 'legacy-eur',
            amount: 50,
            currency: CurrencyCode.eur,
            date: DateTime(2026, 3, 20),
            category: transport,
          ),
          _expense(
            id: 'outside',
            amount: 900,
            currency: CurrencyCode.all,
            date: DateTime(2026, 4, 1),
          ),
        ];
        final useCase = GetExpenseStatisticsUseCase(
          _FakeExpenseRepository(expenses),
        );
        final filter = StatisticsFilter.initial(
          DateTime(2026, 3, 15),
        ).forPeriod(StatisticsPeriod.thisMonth, DateTime(2026, 3, 15));

        final result = await useCase(filter);

        expect(result.totalInAll, 1300);
        expect(result.expenseCount, 3);
        expect(result.unconvertedExpenseCount, 1);
        expect(result.categorySpending, hasLength(1));
        expect(result.categorySpending.single.category.id, 'food');
        expect(result.categorySpending.single.amountInAll, 1300);
        expect(result.monthlySpending.single.month, DateTime(2026, 3));
        expect(result.monthlySpending.single.amountInAll, 1300);
        expect(result.currencyDistribution, hasLength(2));
        expect(
          result.currencyDistribution
              .singleWhere((item) => item.currency == CurrencyCode.eur)
              .originalAmount,
          60,
        );
      },
    );

    test(
      'applies custom date, category, and original currency filters',
      () async {
        final expenses = [
          _expense(
            id: 'matching',
            amount: 10,
            currency: CurrencyCode.eur,
            date: DateTime(2026, 3, 3, 23, 59),
            category: food,
            amountInBaseCurrency: 1000,
            conversionBaseCurrency: CurrencyCode.all,
          ),
          _expense(
            id: 'wrong-category',
            amount: 20,
            currency: CurrencyCode.eur,
            date: DateTime(2026, 3, 4),
            category: transport,
            amountInBaseCurrency: 2000,
            conversionBaseCurrency: CurrencyCode.all,
          ),
          _expense(
            id: 'wrong-currency',
            amount: 30,
            currency: CurrencyCode.usd,
            date: DateTime(2026, 3, 4),
            category: food,
            amountInBaseCurrency: 3000,
            conversionBaseCurrency: CurrencyCode.all,
          ),
          _expense(
            id: 'next-day',
            amount: 40,
            currency: CurrencyCode.eur,
            date: DateTime(2026, 3, 5),
            category: food,
            amountInBaseCurrency: 4000,
            conversionBaseCurrency: CurrencyCode.all,
          ),
        ];
        final useCase = GetExpenseStatisticsUseCase(
          _FakeExpenseRepository(expenses),
        );
        final filter = StatisticsFilter.initial()
            .withCustomRange(DateTime(2026, 3, 3), DateTime(2026, 3, 4))
            .withCategory(food)
            .withCurrency(CurrencyCode.eur);

        final result = await useCase(filter);

        expect(result.totalInAll, 1000);
        expect(result.expenseCount, 1);
        expect(result.currencyDistribution.single.originalAmount, 10);
      },
    );
  });
}
