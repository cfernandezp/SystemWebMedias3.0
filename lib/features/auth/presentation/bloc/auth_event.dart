import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class RegisterRequested extends AuthEvent {
  final RegisterRequestModel request;

  const RegisterRequested({required this.request});

  @override
  List<Object> get props => [request];
}

class ConfirmEmailRequested extends AuthEvent {
  final String token;

  const ConfirmEmailRequested({required this.token});

  @override
  List<Object> get props => [token];
}

class ResendConfirmationRequested extends AuthEvent {
  final String email;

  const ResendConfirmationRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Evento de login (HU-002)
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}

/// Evento de logout (HU-002)
class LogoutRequested extends AuthEvent {}

/// Evento para verificar estado de autenticación (HU-002)
class CheckAuthStatus extends AuthEvent {}
