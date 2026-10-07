import 'entities/currency.dart';
import 'entities/currency_code.dart';

class CurrencyCatalog {
  static const supported = [
    Currency(code: CurrencyCode.all, name: 'Albanian lek', symbol: 'L'),
    Currency(code: CurrencyCode.eur, name: 'Euro', symbol: '€'),
    Currency(code: CurrencyCode.usd, name: 'US dollar', symbol: r'$'),
  ];

  static Currency? find(CurrencyCode code) {
    for (final currency in supported) {
      if (currency.code == code) return currency;
    }
    return null;
  }
}
