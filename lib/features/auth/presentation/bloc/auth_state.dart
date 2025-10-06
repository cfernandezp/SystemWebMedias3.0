import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/auth/data/models/auth_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/email_confirmation_response_model.dart';
import 'package:system_web_medias/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegistered extends AuthState {
  final AuthResponseModel response;

  const AuthRegistered(this.response);

  @override
  List<Object> get props => [response];
}

class AuthEmailConfirmed extends AuthState {
  final EmailConfirmationResponseModel response;

  const AuthEmailConfirmed(this.response);

  @override
  List<Object> get props => [response];
}

class AuthConfirmationResent extends AuthState {
  final String message;

  const AuthConfirmationResent(this.message);

  @override
  List<Object> get props => [message];
}

/// Estado cuando el usuario está autenticado (HU-002)
class AuthAuthenticated extends AuthState {
  final User user;
  final String? message;

  const AuthAuthenticated({
    required this.user,
    this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

/// Estado cuando el usuario no está autenticado (HU-002)
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de logout en progreso (HU-003)
class LogoutInProgress extends AuthState {}

/// Estado de confirmación de logout requerida (HU-003)
class LogoutConfirmationRequired extends AuthState {
  final String message;

  const LogoutConfirmationRequired({
    this.message = '¿Estás seguro que quieres cerrar sesión?',
  });

  @override
  List<Object> get props => [message];
}

/// Estado de logout exitoso (HU-003)
class LogoutSuccess extends AuthState {
  final String message;
  final String logoutType;

  const LogoutSuccess({
    required this.message,
    required this.logoutType,
  });

  @override
  List<Object> get props => [message, logoutType];
}

/// Estado de warning de inactividad (HU-003)
class InactivityWarning extends AuthState {
  final int minutesRemaining;
  final String message;

  const InactivityWarning({
    required this.minutesRemaining,
    required this.message,
  });

  @override
  List<Object> get props => [minutesRemaining, message];
}

/// Estado de token blacklisted (HU-003)
class TokenBlacklisted extends AuthState {
  final String message;
  final String reason;

  const TokenBlacklisted({
    required this.message,
    required this.reason,
  });

  @override
  List<Object> get props => [message, reason];
}

class AuthError extends AuthState {
  final String message;
  final String? errorHint;

  const AuthError(this.message, {this.errorHint});

  @override
  List<Object?> get props => [message, errorHint];
}

/// HU-004: Estados de recuperación de contraseña
class PasswordResetRequestInProgress extends AuthState {}

class PasswordResetRequestSuccess extends AuthState {
  final String message;

  const PasswordResetRequestSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class PasswordResetRequestFailure extends AuthState {
  final String message;

  const PasswordResetRequestFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ResetPasswordInProgress extends AuthState {}

class ResetPasswordSuccess extends AuthState {
  final String message;

  const ResetPasswordSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ResetPasswordFailure extends AuthState {
  final String message;

  const ResetPasswordFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ResetTokenValidationInProgress extends AuthState {}

class ResetTokenValid extends AuthState {
  final String? userId;

  const ResetTokenValid({this.userId});

  @override
  List<Object?> get props => [userId];
}

class ResetTokenInvalid extends AuthState {
  final String message;
  final String? hint; // 'expired', 'invalid', 'used'

  const ResetTokenInvalid({
    required this.message,
    this.hint,
  });

  @override
  List<Object?> get props => [message, hint];
}
