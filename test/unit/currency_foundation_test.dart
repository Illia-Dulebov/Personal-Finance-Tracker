import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/core/constants/app_constants.dart';
import 'package:personal_finance_tracker/features/currency/data/data_sources/static_currency_data_source.dart';
import 'package:personal_finance_tracker/features/currency/data/repositories/static_currency_repository.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/exchange_rate_quote.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';
import 'package:personal_finance_tracker/features/currency/domain/repositories/currency_repository.dart';
import 'package:personal_finance_tracker/features/expenses/data/models/expense_model.dart';
import 'package:personal_finance_tracker/features/expenses/domain/entities/expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/create_expense.dart';
import 'package:personal_finance_tracker/features/expenses/domain/usecases/update_expense.dart';

class _MemoryExpenseRepository implements ExpenseRepository {
  final List<Expense> expenses = [];

  @override
  Future<void> addExpense(Expense expense) async => expenses.add(expense);

  @override
  Future<void> deleteExpense(String id) async =>
      expenses.removeWhere((expense) => expense.id == id);

  @override
  Future<List<Expense>> getExpenses() async => List.of(expenses);

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = expenses.indexWhere((item) => item.id == expense.id);
    if (index != -1) expenses[index] = expense;
  }
}

class _MutableCurrencyRepository implements CurrencyRepository {
  double rate;

  _MutableCurrencyRepository(this.rate);

  @override
  Future<ExchangeRateQuote> getRateToBaseCurrency(
    CurrencyCode currencyCode,
  ) async {
    return ExchangeRateQuote(
      rate: currencyCode == CurrencyCode.all ? 1 : rate,
      capturedAt: DateTime(2026, 1, 1),
    );
  }
}

void main() {
  final category = AppConstants.defaultCategories.first;

  group('Static exchange rates', () {
    test('returns configured conversion rates in ALL', () async {
      final repository = StaticCurrencyRepository(
        dataSource: StaticCurrencyDataSource(),
        clock: () => DateTime(2026, 8, 1),
      );

      final eurQuote = await repository.getRateToBaseCurrency(CurrencyCode.eur);
      final allQuote = await repository.getRateToBaseCurrency(CurrencyCode.all);
      final usdQuote = await repository.getRateToBaseCurrency(CurrencyCode.usd);

      expect(eurQuote.rate, 100);
      expect(allQuote.rate, 1);
      expect(usdQuote.rate, 92);
      expect(eurQuote.capturedAt, DateTime(2026, 8, 1));
    });

    test(
      'rejects unsupported stored codes and invalid reference rates',
      () async {
        await expectLater(
          () => CurrencyCode.fromValue('UAH'),
          throwsFormatException,
        );

        final invalidRepository = StaticCurrencyRepository(
          dataSource: StaticCurrencyDataSource(
            ratesToAll: {
              CurrencyCode.all: 1,
              CurrencyCode.eur: 0,
              CurrencyCode.usd: 92,
            },
          ),
        );
        await expectLater(
          invalidRepository.getRateToBaseCurrency(CurrencyCode.eur),
          throwsStateError,
        );
      },
    );
  });

  group('Historical expense conversion', () {
    test(
      'new foreign currency expense stores an immutable rate snapshot',
      () async {
        final repository = _MemoryExpenseRepository();
        final currencyRepository = _MutableCurrencyRepository(100);
        final createExpense = CreateExpenseUseCase(
          repository,
          currencyRepository,
        );
        final expense = Expense(
          id: 'eur-expense',
          amount: 12.5,
          currency: CurrencyCode.eur,
          date: DateTime(2026, 8, 1),
          category: category,
          paymentMethod: PaymentMethod.card,
          description: 'Dinner',
        );

        await createExpense(expense);

        final created = repository.expenses.single;
        expect(created.amount, 12.5);
        expect(created.currency, CurrencyCode.eur);
        expect(created.amountInBaseCurrency, 1250);
        expect(created.exchangeRateToBaseCurrency, 100);
        expect(created.conversionBaseCurrency, CurrencyCode.all);
        expect(created.conversionRateCapturedAt, DateTime(2026, 1, 1));

        currencyRepository.rate = 120;
        final updateExpense = UpdateExpenseUseCase(repository);
        await updateExpense(created.copyWith(amount: 15));

        final updated = repository.expenses.single;
        expect(updated.amountInBaseCurrency, 1500);
        expect(updated.exchangeRateToBaseCurrency, 100);
        expect(updated.conversionRateCapturedAt, DateTime(2026, 1, 1));
      },
    );

    test('prevents changing the currency after an expense is saved', () async {
      final repository = _MemoryExpenseRepository();
      final createExpense = CreateExpenseUseCase(
        repository,
        StaticCurrencyRepository(dataSource: StaticCurrencyDataSource()),
      );
      final expense = Expense(
        id: 'expense',
        amount: 10,
        currency: CurrencyCode.eur,
        date: DateTime(2026, 8, 1),
        category: category,
        paymentMethod: PaymentMethod.cash,
        description: '',
      );
      await createExpense(expense);

      await expectLater(
        UpdateExpenseUseCase(repository)(
          repository.expenses.single.copyWith(currency: CurrencyCode.usd),
        ),
        throwsStateError,
      );
    });
  });

  group('Legacy expense data', () {
    Map<String, dynamic> legacyJson(String currency) => {
      'id': 'legacy',
      'amount': 50,
      'currency': currency,
      'date': '2026-08-01T00:00:00.000',
      'category': {
        'id': category.id,
        'name': category.name,
        'emoji': category.emoji,
      },
      'paymentMethod': 'cash',
      'description': '',
    };

    test('fills exact conversion metadata for legacy ALL expenses', () {
      final expense = ExpenseModel.fromJson(legacyJson('ALL'));

      expect(expense.amountInBaseCurrency, 50);
      expect(expense.exchangeRateToBaseCurrency, 1);
      expect(expense.conversionBaseCurrency, CurrencyCode.all);
      expect(expense.conversionRateCapturedAt, isNull);
    });

    test('leaves unknown legacy foreign currency conversion unset', () {
      final expense = ExpenseModel.fromJson(legacyJson('EUR'));

      expect(expense.amountInBaseCurrency, isNull);
      expect(expense.exchangeRateToBaseCurrency, isNull);
      expect(expense.conversionBaseCurrency, isNull);
    });

    test('round-trips the historical conversion snapshot through JSON', () {
      final expense = Expense(
        id: 'snapshot',
        amount: 2,
        currency: CurrencyCode.eur,
        date: DateTime(2026, 8, 1),
        category: category,
        paymentMethod: PaymentMethod.card,
        description: 'Coffee',
        amountInBaseCurrency: 200,
        exchangeRateToBaseCurrency: 100,
        conversionBaseCurrency: CurrencyCode.all,
        conversionRateCapturedAt: DateTime(2026, 8, 1, 10),
      );

      final restored = ExpenseModel.fromJson(
        ExpenseModel.fromEntity(expense).toJson(),
      ).toEntity();

      expect(restored.amountInBaseCurrency, 200);
      expect(restored.exchangeRateToBaseCurrency, 100);
      expect(restored.conversionBaseCurrency, CurrencyCode.all);
      expect(restored.conversionRateCapturedAt, DateTime(2026, 8, 1, 10));
    });
  });
}
