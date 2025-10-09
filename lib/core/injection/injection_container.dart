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
import 'package:system_web_medias/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:system_web_medias/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:system_web_medias/features/menu/domain/repositories/menu_repository.dart';
import 'package:system_web_medias/features/menu/domain/usecases/get_menu_options.dart';
import 'package:system_web_medias/features/menu/domain/usecases/update_sidebar_preference.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:system_web_medias/features/user/data/datasources/user_profile_remote_datasource.dart';
import 'package:system_web_medias/features/user/data/repositories/user_profile_repository_impl.dart';
import 'package:system_web_medias/features/user/domain/repositories/user_profile_repository.dart';
import 'package:system_web_medias/features/user/domain/usecases/get_user_profile.dart';
import 'package:system_web_medias/features/catalogos/data/datasources/marcas_remote_datasource.dart';
import 'package:system_web_medias/features/catalogos/data/repositories/marcas_repository_impl.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/marcas_repository.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_bloc.dart';
import 'package:system_web_medias/features/catalogos/data/datasources/materiales_remote_datasource.dart';
import 'package:system_web_medias/features/catalogos/data/repositories/materiales_repository_impl.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/materiales_repository.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/materiales_bloc.dart';
import 'package:system_web_medias/features/catalogos/data/datasources/tipos_remote_datasource.dart';
import 'package:system_web_medias/features/catalogos/data/repositories/tipos_repository_impl.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/tipos_repository.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/tipos_bloc.dart';
import 'package:system_web_medias/features/catalogos/data/datasources/sistemas_talla_remote_datasource.dart';
import 'package:system_web_medias/features/catalogos/data/repositories/sistemas_talla_repository_impl.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/sistemas_talla_repository.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/sistemas_talla/sistemas_talla_bloc.dart';
import 'package:system_web_medias/features/catalogos/data/datasources/colores_remote_datasource.dart';
import 'package:system_web_medias/features/catalogos/data/repositories/colores_repository_impl.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/get_colores_list.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/create_color.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/update_color.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/delete_color.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/get_productos_by_color.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/get_colores_estadisticas.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== CORE - SUPABASE ==========

  // Inicializar Supabase con persistencia de sesión
  await Supabase.initialize(
    url: 'http://127.0.0.1:54321',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      // CRÍTICO: Habilitar persistencia de sesión
      // Esto permite que supabase.auth.currentUser persista entre reinicios
    ),
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
      authRepository: sl(), // HU-003: Inyectar repository para logout seguro
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

  // ========== FEATURES - MENU (HU-002) ==========

  // Bloc
  sl.registerFactory(
    () => MenuBloc(
      getMenuOptions: sl(),
      updateSidebarPreference: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMenuOptions(sl()));
  sl.registerLazySingleton(() => UpdateSidebarPreference(sl()));

  // Repository
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  // ========== FEATURES - USER PROFILE (HU-002) ==========

  // Use Cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));

  // Repository
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(
      supabaseClient: sl(),
    ),
  );

  // ========== FEATURES - CATALOGOS (E002-HU-001, E002-HU-002) ==========

  // Bloc - Marcas
  sl.registerFactory(
    () => MarcasBloc(
      repository: sl(),
    ),
  );

  // Repository - Marcas
  sl.registerLazySingleton<MarcasRepository>(
    () => MarcasRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources - Marcas
  sl.registerLazySingleton<MarcasRemoteDataSource>(
    () => MarcasRemoteDataSourceImpl(
      supabase: sl(),
    ),
  );

  // Bloc - Materiales (E002-HU-002)
  sl.registerFactory(
    () => MaterialesBloc(
      repository: sl(),
    ),
  );

  // Repository - Materiales
  sl.registerLazySingleton<MaterialesRepository>(
    () => MaterialesRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources - Materiales
  sl.registerLazySingleton<MaterialesRemoteDataSource>(
    () => MaterialesRemoteDataSourceImpl(
      sl(),
    ),
  );

  // ========== E002-HU-003: TIPOS ==========

  // Bloc - Tipos
  sl.registerFactory(
    () => TiposBloc(
      repository: sl(),
    ),
  );

  // Repository - Tipos
  sl.registerLazySingleton<TiposRepository>(
    () => TiposRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources - Tipos
  sl.registerLazySingleton<TiposRemoteDataSource>(
    () => TiposRemoteDataSourceImpl(
      sl(),
    ),
  );

  // ========== E002-HU-004: SISTEMAS DE TALLAS ==========

  // Bloc - Sistemas de Tallas
  sl.registerFactory(
    () => SistemasTallaBloc(
      repository: sl(),
    ),
  );

  // Repository - Sistemas de Tallas
  sl.registerLazySingleton<SistemasTallaRepository>(
    () => SistemasTallaRepositoryImpl(
      sl(),
    ),
  );

  // Data Sources - Sistemas de Tallas
  sl.registerLazySingleton<SistemasTallaRemoteDataSource>(
    () => SistemasTallaRemoteDataSourceImpl(
      sl(),
    ),
  );

  // ========== E002-HU-005: COLORES ==========

  // Bloc - Colores
  sl.registerFactory(
    () => ColoresBloc(
      getColoresList: sl(),
      createColor: sl(),
      updateColor: sl(),
      deleteColor: sl(),
      getProductosByColor: sl(),
      getColoresEstadisticas: sl(),
    ),
  );

  // Use Cases - Colores
  sl.registerLazySingleton(() => GetColoresList(sl()));
  sl.registerLazySingleton(() => CreateColor(sl()));
  sl.registerLazySingleton(() => UpdateColor(sl()));
  sl.registerLazySingleton(() => DeleteColor(sl()));
  sl.registerLazySingleton(() => GetProductosByColor(sl()));
  sl.registerLazySingleton(() => GetColoresEstadisticas(sl()));

  // Repository - Colores
  sl.registerLazySingleton<ColoresRepository>(
    () => ColoresRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources - Colores
  sl.registerLazySingleton<ColoresRemoteDataSource>(
    () => ColoresRemoteDataSourceImpl(
      supabase: sl(),
    ),
  );
}
