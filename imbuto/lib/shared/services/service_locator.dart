import 'package:get_it/get_it.dart';
import 'package:imbuto/core/services/api_service.dart';
import 'package:imbuto/features/orders/data/datasources/order_api_service.dart';
import 'package:imbuto/features/orders/data/repositories/order_repository_impl.dart';
import 'package:imbuto/features/orders/domain/repositories/order_repository.dart';
import 'package:imbuto/features/orders/domain/usecases/order_usecases.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/stocks/data/datasources/stock_api_service.dart';
import '../../features/stocks/data/repositories/stock_repository_impl.dart';
import '../../features/stocks/domain/repositories/stock_repository.dart';
import '../../features/stocks/domain/usecases/stock_usecases.dart';
import '../../features/stocks/presentation/bloc/stock_bloc.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/admin_usecases.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/ratings/presentation/bloc/rating_bloc.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // Core
    sl.registerLazySingleton(() => ApiClient(baseUrl: AppConstants.baseUrl));
    sl.registerLazySingleton(() => ApiService(sl()));

    // API Services
    sl.registerLazySingleton(() => StockApiService(sl()));
    sl.registerLazySingleton(() => OrderApiService(sl()));

    // Repositories
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(apiClient: sl()),
    );
    sl.registerLazySingleton<StockRepository>(
      () => StockRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(sl()),
    );
    sl.registerLazySingleton<AdminRepository>(
      () => AdminRepositoryImpl(remoteDataSource: sl()),
    );

    // Use cases - Auth
    sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
    sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));

    // Use cases - Stock
    sl.registerLazySingleton(() => GetStocksUseCase(sl()));
    sl.registerLazySingleton(() => CreateStockUseCase(sl()));
    sl.registerLazySingleton(() => UpdateStockUseCase(sl()));
    sl.registerLazySingleton(() => DeleteStockUseCase(sl()));

    // Use cases - Order
    sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
    sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
    sl.registerLazySingleton(() => UpdateOrderUseCase(sl()));

    // Use cases - Admin
    sl.registerLazySingleton(() => GetPendingUsersUseCase(repository: sl()));
    sl.registerLazySingleton(() => ValidateUserUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetPendingStocksUseCase(repository: sl()));
    sl.registerLazySingleton(() => ValidateStockUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetPendingRolesUseCase(repository: sl()));
    sl.registerLazySingleton(() => ValidateRoleUseCase(repository: sl()));

    // Data sources
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(apiClient: sl()),
    );
    sl.registerLazySingleton(() => AdminRemoteDataSource(apiClient: sl()));

    // BLoCs
    sl.registerFactory(() => AuthBloc(
          loginUseCase: sl(),
          registerUseCase: sl(),
        ));
    sl.registerFactory(() => StockBloc(
          getStocksUseCase: sl(),
          createStockUseCase: sl(),
          updateStockUseCase: sl(),
          deleteStockUseCase: sl(),
        ));
    sl.registerFactory(() => OrderBloc(
          getOrdersUseCase: sl(),
          createOrderUseCase: sl(),
          updateOrderUseCase: sl(),
        ));
    sl.registerFactory(() => AdminBloc(
          getPendingUsersUseCase: sl(),
          validateUserUseCase: sl(),
          getPendingStocksUseCase: sl(),
          validateStockUseCase: sl(),
          getPendingRolesUseCase: sl(),
          validateRoleUseCase: sl(),
        ));
    sl.registerFactory(() => RatingBloc());
  }

  static T get<T extends Object>() => sl<T>();
}
