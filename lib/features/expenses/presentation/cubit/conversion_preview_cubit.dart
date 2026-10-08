import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../currency/domain/entities/currency_code.dart';
import '../../../currency/domain/repositories/currency_repository.dart';
import 'conversion_preview_state.dart';

class ConversionPreviewCubit extends Cubit<ConversionPreviewState> {
  final CurrencyRepository currencyRepository;
  int _request = 0;

  ConversionPreviewCubit({required this.currencyRepository})
    : super(const ConversionPreviewState());

  Future<void> refresh({
    required double? amount,
    required CurrencyCode currency,
    required bool isEditing,
    double? historicalRate,
  }) async {
    final request = ++_request;
    if (amount == null || !amount.isFinite || amount <= 0) {
      emit(const ConversionPreviewState());
      return;
    }

    if (isEditing && historicalRate == null) {
      emit(
        const ConversionPreviewState(
          error: 'No historical conversion is available for this expense.',
        ),
      );
      return;
    }

    emit(const ConversionPreviewState(isLoading: true));

    try {
      final rate =
          historicalRate ??
          (await currencyRepository.getRateToBaseCurrency(currency)).rate;
      final convertedAmount = amount * rate;
      if (!rate.isFinite || rate <= 0 || !convertedAmount.isFinite) {
        throw StateError(
          'The exchange rate produced an invalid converted amount.',
        );
      }
      if (!_isCurrentRequest(request)) return;

      emit(
        ConversionPreviewState(
          preview:
              '${convertedAmount.toStringAsFixed(2)} ${CurrencyCode.all.value}',
        ),
      );
    } on Exception catch (error) {
      _emitError(request, error);
    } on ArgumentError catch (error) {
      _emitError(request, error);
    } on StateError catch (error) {
      _emitError(request, error);
    }
  }

  bool _isCurrentRequest(int request) => !isClosed && request == _request;

  void _emitError(int request, Object error) {
    if (!_isCurrentRequest(request)) return;
    emit(
      ConversionPreviewState(error: 'Unable to calculate conversion: $error'),
    );
  }
}
