import '../../domain/entities/currency_code.dart';

class StaticCurrencyDataSource {
  static const referenceRatesToAll = {
    CurrencyCode.all: 1.0,
    CurrencyCode.eur: 100.0,
    CurrencyCode.usd: 92.0,
  };

  final Map<CurrencyCode, double> ratesToAll;

  StaticCurrencyDataSource({
    Map<CurrencyCode, double> ratesToAll = referenceRatesToAll,
  }) : ratesToAll = Map.unmodifiable(ratesToAll);

  double? getRateToAll(CurrencyCode currencyCode) => ratesToAll[currencyCode];
}
