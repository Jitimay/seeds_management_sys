import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../../core/services/api_service.dart';
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
    sl.registerLazySingleton(() => ApiClient());
    sl.registerLazySingleton(() => ApiService(sl()));
    
    // Data sources
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    );
    
    // Repositories
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl()),
    );
    
    // Use cases
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => RegisterUseCase(sl()));
    
    // BLoCs
    sl.registerFactory(() => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
    ));
  }
  
  static T get<T extends Object>() => sl<T>();
}
