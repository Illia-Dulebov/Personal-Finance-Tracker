import '../../domain/entities/exchange_rate_quote.dart';
import '../../domain/entities/currency_code.dart';
import '../../domain/repositories/currency_repository.dart';
import '../data_sources/static_currency_data_source.dart';

class StaticCurrencyRepository implements CurrencyRepository {
  final StaticCurrencyDataSource dataSource;
  final DateTime Function() _clock;

  StaticCurrencyRepository({
    required this.dataSource,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  @override
  Future<ExchangeRateQuote> getRateToBaseCurrency(
    CurrencyCode currencyCode,
  ) async {
    final rate = dataSource.getRateToAll(currencyCode);
    final baseRate = dataSource.getRateToAll(CurrencyCode.all);
    if (rate == null ||
        baseRate == null ||
        !rate.isFinite ||
        rate <= 0 ||
        !baseRate.isFinite ||
        baseRate <= 0) {
      throw StateError(
        'A valid reference rate is not configured for ${currencyCode.value}.',
      );
    }

    return ExchangeRateQuote(rate: rate / baseRate, capturedAt: _clock());
  }
}
