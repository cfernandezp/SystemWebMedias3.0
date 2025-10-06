import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:system_web_medias/features/auth/data/models/auth_state_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/domain/usecases/confirm_email.dart';
import 'package:system_web_medias/features/auth/domain/usecases/login_user.dart';
import 'package:system_web_medias/features/auth/domain/usecases/logout_user.dart';
import 'package:system_web_medias/features/auth/domain/usecases/register_user.dart';
import 'package:system_web_medias/features/auth/domain/usecases/resend_confirmation.dart';
import 'package:system_web_medias/features/auth/domain/usecases/validate_token.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUserUseCase;
  final ConfirmEmail confirmEmailUseCase;
  final ResendConfirmation resendConfirmationUseCase;
  final LoginUser loginUserUseCase;
  final ValidateToken validateTokenUseCase;
  final LogoutUser logoutUserUseCase;
  final FlutterSecureStorage secureStorage;

  AuthBloc({
    required this.registerUserUseCase,
    required this.confirmEmailUseCase,
    required this.resendConfirmationUseCase,
    required this.loginUserUseCase,
    required this.validateTokenUseCase,
    required this.logoutUserUseCase,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<ConfirmEmailRequested>(_onConfirmEmailRequested);
    on<ResendConfirmationRequested>(_onResendConfirmationRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Validar request antes de llamar al repository
    if (!event.request.isValid) {
      final errors = event.request.validateAll();
      final firstError = errors.values.first;
      emit(AuthError(firstError));
      return;
    }

    emit(AuthLoading());

    final result = await registerUserUseCase(
      RegisterUserParams(request: event.request),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthRegistered(response)),
    );
  }

  Future<void> _onConfirmEmailRequested(
    ConfirmEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await confirmEmailUseCase(
      ConfirmEmailParams(token: event.token),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(AuthEmailConfirmed(response)),
    );
  }

  Future<void> _onResendConfirmationRequested(
    ResendConfirmationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await resendConfirmationUseCase(
      ResendConfirmationParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthConfirmationResent('Email de confirmación reenviado')),
    );
  }

  /// HU-002: Manejar evento de login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final request = LoginRequestModel(
      email: event.email,
      password: event.password,
      rememberMe: event.rememberMe,
    );

    final result = await loginUserUseCase(request);

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (response) async {
        // Guardar en SecureStorage
        final authState = AuthStateModel(
          token: response.token,
          user: response.user,
          tokenExpiration: DateTime.now().add(
            event.rememberMe ? const Duration(days: 30) : const Duration(hours: 8),
          ),
        );

        await secureStorage.write(
          key: 'auth_state',
          value: jsonEncode(authState.toJson()),
        );

        emit(AuthAuthenticated(
          user: response.user,
          message: response.message,
        ));
      },
    );
  }

  /// HU-002: Manejar evento de logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await secureStorage.delete(key: 'auth_state');
    emit(const AuthUnauthenticated());
  }

  /// HU-002: Verificar estado de autenticación al iniciar
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Leer de SecureStorage
    final authStateJson = await secureStorage.read(key: 'auth_state');

    if (authStateJson == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final authState = AuthStateModel.fromJson(jsonDecode(authStateJson));

      // Verificar si el token expiró localmente
      if (authState.isExpired) {
        await secureStorage.delete(key: 'auth_state');
        emit(const AuthUnauthenticated(message: 'Tu sesión ha expirado'));
        return;
      }

      // Si hay token, validarlo con el backend
      if (authState.token != null) {
        final result = await validateTokenUseCase(authState.token!);

        result.fold(
          (failure) async {
            await secureStorage.delete(key: 'auth_state');
            emit(AuthUnauthenticated(message: failure.message));
          },
          (response) {
            emit(AuthAuthenticated(user: response.user));
          },
        );
      } else {
        // Sin token JWT real, confiar en la sesión local si no ha expirado
        // Esto es temporal hasta que el backend implemente tokens JWT
        emit(AuthAuthenticated(user: authState.user));
      }
    } catch (e) {
      await secureStorage.delete(key: 'auth_state');
      emit(const AuthUnauthenticated(message: 'Error al verificar sesión'));
    }
  }
}
