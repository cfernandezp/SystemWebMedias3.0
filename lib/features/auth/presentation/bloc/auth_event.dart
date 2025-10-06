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

/// Evento de logout (HU-002, HU-003)
class LogoutRequested extends AuthEvent {
  final String logoutType; // 'manual', 'inactivity', 'token_expired'

  const LogoutRequested({this.logoutType = 'manual'});

  @override
  List<Object> get props => [logoutType];
}

/// Evento para cancelar logout (HU-003)
class LogoutCancelled extends AuthEvent {}

/// Evento para detectar inactividad (HU-003)
class InactivityDetected extends AuthEvent {}

/// Evento para extender sesión (HU-003)
class ExtendSessionRequested extends AuthEvent {}

/// Evento para verificar token blacklist (HU-003)
class TokenBlacklistCheckRequested extends AuthEvent {
  final String token;

  const TokenBlacklistCheckRequested(this.token);

  @override
  List<Object> get props => [token];
}

/// Evento para verificar estado de autenticación (HU-002)
class CheckAuthStatus extends AuthEvent {}

/// HU-004: Eventos de recuperación de contraseña
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [token, newPassword];
}

class ValidateResetTokenRequested extends AuthEvent {
  final String token;

  const ValidateResetTokenRequested({required this.token});

  @override
  List<Object> get props => [token];
}
