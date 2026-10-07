import 'package:equatable/equatable.dart';
import 'currency_code.dart';

class Currency extends Equatable {
  final CurrencyCode code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  @override
  List<Object?> get props => [code, name, symbol];
}
