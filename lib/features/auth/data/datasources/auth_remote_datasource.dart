import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/auth/data/models/auth_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/email_confirmation_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/inactivity_status_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/password_reset_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/password_reset_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/reset_password_model.dart';
import 'package:system_web_medias/features/auth/data/models/token_blacklist_check_model.dart';
import 'package:system_web_medias/features/auth/data/models/validate_reset_token_model.dart';
import 'package:system_web_medias/features/auth/data/models/validate_token_response_model.dart';

/// Abstract DataSource
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<EmailConfirmationResponseModel> confirmEmail(String token);
  Future<void> resendConfirmation(String email);

  /// HU-002: Login methods
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<ValidateTokenResponseModel> validateToken(String token);

  /// HU-003: Logout Seguro methods
  Future<LogoutResponseModel> logout(LogoutRequestModel request);
  Future<TokenBlacklistCheckModel> checkTokenBlacklist(String token);
  Future<InactivityStatusModel> checkInactivity(String userId);
  Future<void> updateUserActivity(String userId);

  /// HU-004: Password Recovery methods
  Future<PasswordResetResponseModel> requestPasswordReset(PasswordResetRequestModel request);
  Future<void> resetPassword(ResetPasswordModel request);
  Future<ValidateResetTokenModel> validateResetToken(String token);
}

/// Implementation usando Supabase Database Functions (RPC)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({
    required this.supabase,
  });

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      print('🔵 Llamando a auth.signUp con email: ${request.email}');

      final response = await supabase.auth.signUp(
        email: request.email,
        password: request.password,
        data: {
          'nombre_completo': request.nombreCompleto,
        },
      );

      print('🔵 Respuesta recibida de Supabase Auth');
      print('🔵 User ID: ${response.user?.id}');
      print('🔵 Email confirmed: ${response.user?.emailConfirmedAt}');

      if (response.user == null) {
        print('❌ Usuario no creado');
        throw ServerException('No se pudo crear el usuario', 500);
      }

      print('✅ Registro exitoso - User ID: ${response.user!.id}');

      // Convertir respuesta de Supabase Auth al formato AuthResponseModel
      return AuthResponseModel(
        id: response.user!.id,
        email: response.user!.email ?? request.email,
        nombreCompleto: request.nombreCompleto,
        estado: response.user!.emailConfirmedAt != null ? 'ACTIVO' : 'REGISTRADO',
        emailVerificado: response.user!.emailConfirmedAt != null,
        message: 'Registro exitoso. Revisa tu email para confirmar tu cuenta',
      );
    } catch (e) {
      print('❌ Exception capturada: $e');
      if (e is AppException) {
        rethrow;
      }
      if (e is AuthException) {
        // Mapear errores de Supabase Auth
        if (e.message.contains('already registered') || e.message.contains('already exists')) {
          throw DuplicateEmailException('Este email ya está registrado', 409);
        } else if (e.message.contains('invalid')) {
          throw ValidationException(e.message, 400);
        }
        throw ServerException(e.message, 500);
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<EmailConfirmationResponseModel> confirmEmail(String token) async {
    try {
      print('🔵 Llamando a auth.verifyOTP con token: $token');

      final response = await supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: token,
        email: '', // Supabase extrae el email del token
      );

      print('🔵 Email confirmado exitosamente');
      print('🔵 User ID: ${response.user?.id}');

      if (response.user == null) {
        throw InvalidTokenException('Token inválido o expirado', 400);
      }

      return EmailConfirmationResponseModel(
        message: 'Email confirmado exitosamente',
        emailVerificado: true,
        estado: 'ACTIVO',
        nextStep: '/login', // Redirigir al login después de confirmar
      );
    } catch (e) {
      print('❌ Exception en confirmEmail: $e');
      if (e is AppException) {
        rethrow;
      }
      if (e is AuthException) {
        if (e.message.contains('expired') || e.message.contains('invalid')) {
          throw InvalidTokenException('Token inválido o expirado', 400);
        } else if (e.message.contains('already')) {
          throw EmailAlreadyVerifiedException('Este email ya fue confirmado', 400);
        }
        throw ServerException(e.message, 500);
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<void> resendConfirmation(String email) async {
    try {
      print('🔵 Llamando a auth.resend para email: $email');

      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      print('✅ Email de confirmación reenviado');
    } catch (e) {
      print('❌ Exception en resendConfirmation: $e');
      if (e is AppException) {
        rethrow;
      }
      if (e is AuthException) {
        if (e.message.contains('already confirmed')) {
          throw EmailAlreadyVerifiedException('Este email ya fue confirmado', 400);
        } else if (e.message.contains('rate limit') || e.message.contains('too many')) {
          throw RateLimitException('Demasiados intentos. Intenta más tarde', 429);
        } else if (e.message.contains('not found')) {
          throw ValidationException('No se encontró un usuario con ese email', 404);
        }
        throw ServerException(e.message, 500);
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-002: Login con credenciales
  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      print('🔵 Llamando a login_user con email: ${request.email}');

      final response = await supabase.rpc('login_user', params: request.toJson());
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de login_user');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Login exitoso');
        return LoginResponseModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en login - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'invalid_credentials') {
          throw UnauthorizedException(message, 401);
        } else if (hint == 'email_not_verified') {
          throw EmailNotVerifiedException(message, 403);
        } else if (hint == 'user_not_approved') {
          throw UserNotApprovedException(message, 403);
        } else if (hint == 'missing_email' || hint == 'invalid_email' || hint == 'missing_password') {
          throw ValidationException(message, 400);
        } else if (hint == 'rate_limit_exceeded') {
          throw RateLimitException(message, 429);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en login: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-002: Validar token de sesión
  @override
  Future<ValidateTokenResponseModel> validateToken(String token) async {
    try {
      print('🔵 Llamando a validate_token');

      final response = await supabase.rpc('validate_token', params: {'p_token': token});
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de validate_token');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Token válido');
        return ValidateTokenResponseModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en validate_token - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'expired_token' || hint == 'invalid_token' || hint == 'missing_token') {
          throw UnauthorizedException(message, 401);
        } else if (hint == 'user_not_found') {
          throw ValidationException(message, 404);
        } else if (hint == 'user_not_approved') {
          throw UserNotApprovedException(message, 403);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en validateToken: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-003: Logout seguro con invalidación de token
  @override
  Future<LogoutResponseModel> logout(LogoutRequestModel request) async {
    try {
      print('🔵 Llamando a logout_user con userId: ${request.userId}');

      final response = await supabase.rpc('logout_user', params: request.toJson());
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de logout_user');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Logout exitoso');
        return LogoutResponseModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en logout - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas según 00-CONVENTIONS.md
        if (hint == 'token_blacklisted') {
          throw TokenBlacklistedException(message, 401);
        } else if (hint == 'already_blacklisted') {
          throw AlreadyLoggedOutException(message, 400);
        } else if (hint == 'missing_token' || hint == 'missing_user_id') {
          throw ValidationException(message, 400);
        } else if (hint == 'invalid_logout_type') {
          throw ValidationException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en logout: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-003: Verificar si token está en blacklist
  @override
  Future<TokenBlacklistCheckModel> checkTokenBlacklist(String token) async {
    try {
      print('🔵 Llamando a check_token_blacklist');

      final response = await supabase.rpc('check_token_blacklist', params: {'p_token': token});
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de check_token_blacklist');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Token verificado');
        return TokenBlacklistCheckModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en check_token_blacklist - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'missing_token') {
          throw ValidationException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en checkTokenBlacklist: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-003: Verificar estado de inactividad del usuario
  @override
  Future<InactivityStatusModel> checkInactivity(String userId) async {
    try {
      print('🔵 Llamando a check_user_inactivity con userId: $userId');

      final response = await supabase.rpc('check_user_inactivity', params: {
        'p_user_id': userId,
        'p_timeout_minutes': 120, // 2 horas - timeout estándar
      });
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de check_user_inactivity');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Estado de inactividad obtenido');
        return InactivityStatusModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en check_user_inactivity - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'missing_user_id') {
          throw ValidationException(message, 400);
        } else if (hint == 'user_not_found') {
          throw UserNotFoundException(message, 404);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en checkInactivity: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-003: Actualizar última actividad del usuario
  @override
  Future<void> updateUserActivity(String userId) async {
    try {
      print('🔵 Llamando a update_user_activity con userId: $userId');

      final response = await supabase.rpc('update_user_activity', params: {
        'p_user_id': userId,
      });
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de update_user_activity');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Actividad actualizada');
        return;
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en update_user_activity - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'missing_user_id') {
          throw ValidationException(message, 400);
        } else if (hint == 'user_not_found') {
          throw UserNotFoundException(message, 404);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en updateUserActivity: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-004: Solicitar recuperación de contraseña
  @override
  Future<PasswordResetResponseModel> requestPasswordReset(
    PasswordResetRequestModel request,
  ) async {
    try {
      print('🔵 Llamando a request_password_reset con email: ${request.email}');

      final response = await supabase.rpc(
        'request_password_reset',
        params: request.toJson(),
      );
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de request_password_reset');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Solicitud de recuperación exitosa');
        return PasswordResetResponseModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en request_password_reset - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'invalid_email') {
          throw ValidationException(message, 400);
        } else if (hint == 'rate_limit') {
          throw RateLimitException(message, 429);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en requestPasswordReset: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-004: Validar token de recuperación
  @override
  Future<ValidateResetTokenModel> validateResetToken(String token) async {
    try {
      print('🔵 Llamando a validate_reset_token');

      final response = await supabase.rpc(
        'validate_reset_token',
        params: {'p_token': token},
      );
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de validate_reset_token');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Token válido');
        return ValidateResetTokenModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en validate_reset_token - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'missing_token') {
          throw ValidationException(message, 400);
        } else if (hint == 'invalid_token') {
          throw InvalidTokenException(message, 400);
        } else if (hint == 'expired_token') {
          throw ExpiredTokenException(message, 400);
        } else if (hint == 'used_token') {
          throw UsedTokenException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en validateResetToken: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// HU-004: Cambiar contraseña con token
  @override
  Future<void> resetPassword(ResetPasswordModel request) async {
    try {
      print('🔵 Llamando a Edge Function reset-password');

      // Usar Edge Function en lugar de RPC para evitar conflictos con auth.users
      final response = await supabase.functions.invoke(
        'reset-password',
        body: request.toJson(),
      );

      print('🔵 Respuesta recibida de reset-password');
      print('🔵 Status: ${response.status}');

      if (response.status != 200) {
        final error = response.data as Map<String, dynamic>?;
        final errorDetails = error?['error'] as Map<String, dynamic>?;
        final hint = errorDetails?['hint'] as String?;
        final message = errorDetails?['message'] as String? ?? 'Error desconocido';

        print('❌ Error en reset-password - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'missing_params') {
          throw ValidationException(message, 400);
        } else if (hint == 'weak_password') {
          throw WeakPasswordException(message, 400);
        } else if (hint == 'invalid_token') {
          throw InvalidTokenException(message, 400);
        } else if (hint == 'expired_token') {
          throw ExpiredTokenException(message, 400);
        } else if (hint == 'used_token') {
          throw UsedTokenException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en resetPassword: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }
}
