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

class AuthError extends AuthState {
  final String message;
  final String? errorHint;

  const AuthError(this.message, {this.errorHint});

  @override
  List<Object?> get props => [message, errorHint];
}
