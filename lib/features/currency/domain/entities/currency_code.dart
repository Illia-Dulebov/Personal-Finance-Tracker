enum CurrencyCode {
  all('ALL'),
  eur('EUR'),
  usd('USD');

  final String value;

  const CurrencyCode(this.value);

  static CurrencyCode fromValue(String value) {
    return CurrencyCode.values.firstWhere(
      (currency) => currency.value == value,
      orElse: () => throw FormatException('Unsupported currency code: $value'),
    );
  }
}
