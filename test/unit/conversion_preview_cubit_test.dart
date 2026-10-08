import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/currency_code.dart';
import 'package:personal_finance_tracker/features/currency/domain/entities/exchange_rate_quote.dart';
import 'package:personal_finance_tracker/features/currency/domain/repositories/currency_repository.dart';
import 'package:personal_finance_tracker/features/expenses/presentation/cubit/conversion_preview_cubit.dart';

class _FakeCurrencyRepository implements CurrencyRepository {
  final Future<ExchangeRateQuote> Function(CurrencyCode currencyCode) onGetRate;

  _FakeCurrencyRepository(this.onGetRate);

  @override
  Future<ExchangeRateQuote> getRateToBaseCurrency(CurrencyCode currencyCode) =>
      onGetRate(currencyCode);
}

void main() {
  group('ConversionPreviewCubit', () {
    test('loads and formats the base-currency estimate', () async {
      final cubit = ConversionPreviewCubit(
        currencyRepository: _FakeCurrencyRepository(
          (_) async => ExchangeRateQuote(rate: 100, capturedAt: DateTime(2026)),
        ),
      );
      addTearDown(cubit.close);

      await cubit.refresh(
        amount: 10,
        currency: CurrencyCode.eur,
        isEditing: false,
      );

      expect(cubit.state.preview, '1000.00 ALL');
      expect(cubit.state.error, isNull);
      expect(cubit.state.isLoading, isFalse);
    });

    test('uses the historical rate when editing', () async {
      var repositoryCalled = false;
      final cubit = ConversionPreviewCubit(
        currencyRepository: _FakeCurrencyRepository((_) async {
          repositoryCalled = true;
          return ExchangeRateQuote(rate: 200, capturedAt: DateTime(2026));
        }),
      );
      addTearDown(cubit.close);

      await cubit.refresh(
        amount: 10,
        currency: CurrencyCode.eur,
        isEditing: true,
        historicalRate: 150,
      );

      expect(cubit.state.preview, '1500.00 ALL');
      expect(repositoryCalled, isFalse);
    });

    test('ignores an older conversion result', () async {
      final firstRate = Completer<ExchangeRateQuote>();
      final cubit = ConversionPreviewCubit(
        currencyRepository: _FakeCurrencyRepository(
          (currency) => currency == CurrencyCode.all
              ? Future.value(
                  ExchangeRateQuote(rate: 100, capturedAt: DateTime(2026)),
                )
              : firstRate.future,
        ),
      );
      addTearDown(cubit.close);

      final olderRequest = cubit.refresh(
        amount: 10,
        currency: CurrencyCode.eur,
        isEditing: false,
      );
      await cubit.refresh(
        amount: 20,
        currency: CurrencyCode.all,
        isEditing: false,
      );
      firstRate.complete(
        ExchangeRateQuote(rate: 100, capturedAt: DateTime(2026)),
      );
      await olderRequest;

      expect(cubit.state.preview, '2000.00 ALL');
    });
  });
}
