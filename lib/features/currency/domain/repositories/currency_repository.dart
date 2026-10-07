import '../entities/exchange_rate_quote.dart';
import '../entities/currency_code.dart';

abstract interface class CurrencyRepository {
  Future<ExchangeRateQuote> getRateToBaseCurrency(CurrencyCode currencyCode);
}
