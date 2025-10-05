import 'package:equatable/equatable.dart';

class EmailConfirmationResponseModel extends Equatable {
  final String message;
  final bool emailVerificado;
  final String estado;
  final String nextStep;

  const EmailConfirmationResponseModel({
    required this.message,
    required this.emailVerificado,
    required this.estado,
    required this.nextStep,
  });

  factory EmailConfirmationResponseModel.fromJson(Map<String, dynamic> json) {
    return EmailConfirmationResponseModel(
      message: json['message'] as String,
      emailVerificado: json['email_verificado'] as bool,
      estado: json['estado'] as String,
      nextStep: json['next_step'] as String,
    );
  }

  @override
  List<Object?> get props => [message, emailVerificado, estado, nextStep];
}
