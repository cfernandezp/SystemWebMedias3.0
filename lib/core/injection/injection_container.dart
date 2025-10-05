import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:system_web_medias/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';
import 'package:system_web_medias/features/auth/domain/usecases/confirm_email.dart';
import 'package:system_web_medias/features/auth/domain/usecases/login_user.dart';
import 'package:system_web_medias/features/auth/domain/usecases/logout_user.dart';
import 'package:system_web_medias/features/auth/domain/usecases/register_user.dart';
import 'package:system_web_medias/features/auth/domain/usecases/resend_confirmation.dart';
import 'package:system_web_medias/features/auth/domain/usecases/validate_token.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== CORE - SUPABASE ==========

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'http://127.0.0.1:54321',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );

  // Registrar Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Registrar Flutter Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());

  // ========== FEATURES - AUTH ==========

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      registerUserUseCase: sl(),
      confirmEmailUseCase: sl(),
      resendConfirmationUseCase: sl(),
      loginUserUseCase: sl(),
      validateTokenUseCase: sl(),
      logoutUserUseCase: sl(),
      secureStorage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => ConfirmEmail(sl()));
  sl.registerLazySingleton(() => ResendConfirmation(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => ValidateToken(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabase: sl(),
    ),
  );
}
