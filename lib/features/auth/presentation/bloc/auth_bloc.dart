import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/models/auth_state_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_request_model.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';
import 'package:system_web_medias/features/auth/domain/services/inactivity_timer_service.dart';
import 'package:system_web_medias/features/auth/domain/services/multi_tab_sync_service.dart';
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

  // HU-003: Services para logout seguro
  final AuthRepository authRepository;
  InactivityTimerService? _inactivityTimerService;
  MultiTabSyncService? _multiTabSyncService;
  StreamSubscription<String>? _multiTabSubscription;

  AuthBloc({
    required this.registerUserUseCase,
    required this.confirmEmailUseCase,
    required this.resendConfirmationUseCase,
    required this.loginUserUseCase,
    required this.validateTokenUseCase,
    required this.logoutUserUseCase,
    required this.secureStorage,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<ConfirmEmailRequested>(_onConfirmEmailRequested);
    on<ResendConfirmationRequested>(_onResendConfirmationRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);

    // HU-003: Event handlers para logout seguro
    on<InactivityDetected>(_onInactivityDetected);
    on<ExtendSessionRequested>(_onExtendSessionRequested);
    on<TokenBlacklistCheckRequested>(_onTokenBlacklistCheckRequested);

    // HU-004: Event handlers para password recovery
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ValidateResetTokenRequested>(_onValidateResetTokenRequested);

    // HU-003: Inicializar servicios de sincronización multi-pestaña
    _initializeMultiTabSync();
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

        // HU-003: Guardar token en auth_token para multi-tab sync
        await secureStorage.write(
          key: 'auth_token',
          value: response.token,
        );

        // HU-003: Iniciar timer de inactividad
        _startInactivityTimer();

        emit(AuthAuthenticated(
          user: response.user,
          message: response.message,
        ));
      },
    );
  }

  /// HU-003: Manejar evento de logout seguro
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(LogoutInProgress());

    try {
      // Obtener token y userId del SecureStorage
      final authStateJson = await secureStorage.read(key: 'auth_state');
      final token = await secureStorage.read(key: 'auth_token');

      if (authStateJson == null || token == null) {
        // Si no hay sesión activa, solo limpiar y salir
        await _cleanupSession();
        emit(const AuthUnauthenticated());
        return;
      }

      final authState = AuthStateModel.fromJson(jsonDecode(authStateJson));

      // Crear request de logout
      final logoutRequest = LogoutRequestModel(
        token: token,
        userId: authState.user.id,
        logoutType: event.logoutType,
        // TODO: Obtener IP y User-Agent en futuras versiones
      );

      // Llamar repository para logout seguro
      final result = await authRepository.logoutSecure(logoutRequest);

      await result.fold(
        (failure) async {
          // Incluso si falla el backend, limpiar sesión local
          await _cleanupSession();
          emit(AuthError(failure.message));
        },
        (response) async {
          // Limpiar sesión local
          await _cleanupSession();

          // Notificar otras pestañas
          _multiTabSyncService?.notifyLogout();

          // Detener timer de inactividad
          _stopInactivityTimer();

          emit(LogoutSuccess(
            message: response.message,
            logoutType: response.logoutType,
          ));
        },
      );
    } catch (e) {
      // En caso de error, limpiar sesión local
      await _cleanupSession();
      emit(AuthError('Error al cerrar sesión: ${e.toString()}'));
    }
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
            // HU-003: Iniciar timer de inactividad si sesión válida
            _startInactivityTimer();
            emit(AuthAuthenticated(user: response.user));
          },
        );
      } else {
        // Sin token JWT real, confiar en la sesión local si no ha expirado
        // Esto es temporal hasta que el backend implemente tokens JWT
        // HU-003: Iniciar timer de inactividad
        _startInactivityTimer();
        emit(AuthAuthenticated(user: authState.user));
      }
    } catch (e) {
      await secureStorage.delete(key: 'auth_state');
      emit(const AuthUnauthenticated(message: 'Error al verificar sesión'));
    }
  }

  // ========== HU-003: Event Handlers para Logout Seguro ==========

  /// HU-003: Manejar detección de inactividad
  Future<void> _onInactivityDetected(
    InactivityDetected event,
    Emitter<AuthState> emit,
  ) async {
    // Logout automático por inactividad
    add(const LogoutRequested(logoutType: 'inactivity'));
  }

  /// HU-003: Manejar extensión de sesión
  Future<void> _onExtendSessionRequested(
    ExtendSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Obtener userId del SecureStorage
      final authStateJson = await secureStorage.read(key: 'auth_state');
      if (authStateJson == null) return;

      final authState = AuthStateModel.fromJson(jsonDecode(authStateJson));

      // Resetear timer de inactividad
      _inactivityTimerService?.resetTimer();

      // Actualizar actividad en backend
      await authRepository.updateUserActivity(authState.user.id);

      // Notificar otras pestañas
      _multiTabSyncService?.notifySessionExtended();
    } catch (e) {
      // Silently fail - no afectar UX si falla update de actividad
    }
  }

  /// HU-003: Verificar si token está en blacklist
  Future<void> _onTokenBlacklistCheckRequested(
    TokenBlacklistCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.checkTokenBlacklist(event.token);

    result.fold(
      (failure) {
        // Si falla la verificación, asumir que está OK
      },
      (checkResult) {
        if (checkResult.isBlacklisted) {
          // Token está en blacklist - forzar logout
          _cleanupSession();
          emit(TokenBlacklisted(
            message: checkResult.message,
            reason: checkResult.reason ?? 'Token inválido',
          ));
        }
      },
    );
  }

  // ========== HU-003: Helper Methods ==========

  /// Inicializar servicio de sincronización multi-pestaña
  void _initializeMultiTabSync() {
    _multiTabSyncService = MultiTabSyncService();

    // Escuchar eventos de otras pestañas
    _multiTabSubscription = _multiTabSyncService!.storageEvents.listen((event) {
      if (event == 'logout_detected') {
        // Logout detectado en otra pestaña
        add(const LogoutRequested(logoutType: 'multi_tab'));
      } else if (event == 'session_extended') {
        // Sesión extendida en otra pestaña - resetear timer local
        _inactivityTimerService?.resetTimer();
      }
    });
  }

  /// Iniciar timer de inactividad
  void _startInactivityTimer() {
    _inactivityTimerService = InactivityTimerService(
      onInactive: () {
        // Callback cuando se detecta inactividad
        add(InactivityDetected());
      },
      onWarning: (minutesRemaining) {
        // Callback para warning de inactividad
        // TODO: Mostrar dialog de warning (se maneja en UI layer con BlocListener)
      },
    );

    _inactivityTimerService!.startTimer();
  }

  /// Detener timer de inactividad
  void _stopInactivityTimer() {
    _inactivityTimerService?.stopTimer();
    _inactivityTimerService?.dispose();
    _inactivityTimerService = null;
  }

  /// Limpiar sesión local (SecureStorage)
  Future<void> _cleanupSession() async {
    await secureStorage.delete(key: 'auth_state');
    await secureStorage.delete(key: 'auth_token');
  }

  /// Resetear timer de inactividad (llamar en cada interacción del usuario)
  void resetInactivityTimer() {
    _inactivityTimerService?.resetTimer();
  }

  // ========== HU-004: Event Handlers para Password Recovery ==========

  /// HU-004: Manejar solicitud de recuperación de contraseña
  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(PasswordResetRequestInProgress());

    final result = await authRepository.requestPasswordReset(event.email);

    result.fold(
      (failure) => emit(PasswordResetRequestFailure(message: failure.message)),
      (response) => emit(PasswordResetRequestSuccess(message: response.message)),
    );
  }

  /// HU-004: Manejar cambio de contraseña con token
  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetPasswordInProgress());

    final result = await authRepository.resetPassword(
      event.token,
      event.newPassword,
    );

    result.fold(
      (failure) => emit(ResetPasswordFailure(message: failure.message)),
      (_) => emit(const ResetPasswordSuccess(
        message: 'Contraseña cambiada exitosamente',
      )),
    );
  }

  /// HU-004: Manejar validación de token de recuperación
  Future<void> _onValidateResetTokenRequested(
    ValidateResetTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetTokenValidationInProgress());

    final result = await authRepository.validateResetToken(event.token);

    result.fold(
      (failure) {
        // Determinar hint según tipo de failure
        String? hint;
        if (failure is ExpiredTokenFailure) {
          hint = 'expired';
        } else if (failure is UsedTokenFailure) {
          hint = 'used';
        } else if (failure is InvalidTokenFailure) {
          hint = 'invalid';
        }

        emit(ResetTokenInvalid(
          message: failure.message,
          hint: hint,
        ));
      },
      (validateResult) => emit(ResetTokenValid(userId: validateResult.userId)),
    );
  }

  @override
  Future<void> close() {
    // Limpiar recursos al cerrar el bloc
    _stopInactivityTimer();
    _multiTabSubscription?.cancel();
    _multiTabSyncService?.dispose();
    return super.close();
  }
}
