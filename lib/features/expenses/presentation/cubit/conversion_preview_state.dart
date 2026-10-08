import 'package:equatable/equatable.dart';

class ConversionPreviewState extends Equatable {
  final String? preview;
  final String? error;
  final bool isLoading;

  const ConversionPreviewState({
    this.preview,
    this.error,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [preview, error, isLoading];
}
