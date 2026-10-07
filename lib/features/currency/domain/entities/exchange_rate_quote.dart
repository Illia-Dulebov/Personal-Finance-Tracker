import 'package:equatable/equatable.dart';

class ExchangeRateQuote extends Equatable {
  final double rate;
  final DateTime capturedAt;

  const ExchangeRateQuote({required this.rate, required this.capturedAt});

  @override
  List<Object?> get props => [rate, capturedAt];
}
