import 'package:equatable/equatable.dart';

class ErrorResponseModel extends Equatable {
  final String error;
  final String message;
  final String? field;

  const ErrorResponseModel({
    required this.error,
    required this.message,
    this.field,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      error: json['error'] as String,
      message: json['message'] as String,
      field: json['field'] as String?,
    );
  }

  @override
  List<Object?> get props => [error, message, field];

  // Helper methods para identificar tipos de error
  bool get isDuplicateEmail => error == 'DUPLICATE_EMAIL';
  bool get isValidationError => error == 'VALIDATION_ERROR';
  bool get isInvalidToken => error == 'INVALID_TOKEN';
  bool get isRateLimitExceeded => error == 'RATE_LIMIT_EXCEEDED';
  bool get isEmailAlreadyVerified => error == 'EMAIL_ALREADY_VERIFIED';
}
