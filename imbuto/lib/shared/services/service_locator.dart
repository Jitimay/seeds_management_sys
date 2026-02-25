import 'package:get_it/get_it.dart';
import 'package:imbuto/core/services/api_service.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // Core
    sl.registerLazySingleton(() => ApiClient(baseUrl: AppConstants.baseUrl));
    sl.registerLazySingleton(() => ApiService(sl()));

    // Data sources
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(apiClient: sl()),
    );

    // Repositories
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(apiClient: sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
    sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));

    // BLoCs
    sl.registerFactory(() => AuthBloc(
          loginUseCase: sl(),
          registerUseCase: sl(),
        ));
  }

  static T get<T extends Object>() => sl<T>();
}
