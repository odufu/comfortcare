import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/network_info.dart';
import '../core/storage/local_storage_service.dart';
import '../core/theme/bloc/theme_bloc.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user.dart';
import '../features/auth/domain/usecases/login.dart';
import '../features/auth/domain/usecases/logout.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

import '../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/domain/usecases/get_dashboard_data.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../features/products/data/datasources/products_remote_datasource.dart';
import '../features/products/data/repositories/products_repository_impl.dart';
import '../features/products/domain/repositories/products_repository.dart';
import '../features/products/domain/usecases/get_products.dart';
import '../features/products/presentation/bloc/products_bloc.dart';

import '../features/cart/data/datasources/cart_local_datasource.dart';
import '../features/cart/data/repositories/cart_repository_impl.dart';
import '../features/cart/domain/repositories/cart_repository.dart';
import '../features/cart/domain/usecases/manage_cart.dart';
import '../features/cart/presentation/bloc/cart_bloc.dart';

import '../features/orders/data/datasources/orders_remote_datasource.dart';
import '../features/orders/data/repositories/orders_repository_impl.dart';
import '../features/orders/domain/repositories/orders_repository.dart';
import '../features/orders/domain/usecases/manage_orders.dart';
import '../features/orders/presentation/bloc/orders_bloc.dart';

import '../features/payments/data/datasources/payments_remote_datasource.dart';
import '../features/payments/data/repositories/payments_repository_impl.dart';
import '../features/payments/domain/repositories/payments_repository.dart';
import '../features/payments/domain/usecases/process_payment.dart';
import '../features/payments/presentation/bloc/payments_bloc.dart';

import '../features/clinical/data/datasources/clinical_remote_datasource.dart';
import '../features/clinical/data/repositories/clinical_repository_impl.dart';
import '../features/clinical/domain/repositories/clinical_repository.dart';
import '../features/clinical/domain/usecases/manage_clinical.dart';
import '../features/clinical/presentation/bloc/clinical_bloc.dart';

import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/manage_profile.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // SharedPreferences & Core Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Theme Bloc
  sl.registerFactory(() => ThemeBloc(storageService: sl()));

  // Auth Feature
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Dashboard Feature
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl()));
  sl.registerFactory(
    () => DashboardBloc(getDashboardDataUseCase: sl()),
  );

  // Products Feature
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerFactory(
    () => ProductsBloc(getProductsUseCase: sl()),
  );

  // Cart Feature
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ManageCartUseCase(sl()));
  sl.registerFactory(
    () => CartBloc(manageCartUseCase: sl()),
  );

  // Orders Feature
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ManageOrdersUseCase(sl()));
  sl.registerFactory(
    () => OrdersBloc(manageOrdersUseCase: sl()),
  );

  // Payments Feature
  sl.registerLazySingleton<PaymentsRemoteDataSource>(
    () => PaymentsRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerFactory(
    () => PaymentsBloc(processPaymentUseCase: sl()),
  );

  // Clinical Feature
  sl.registerLazySingleton<ClinicalRemoteDataSource>(
    () => ClinicalRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ClinicalRepository>(
    () => ClinicalRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ManageClinicalUseCase(sl()));
  sl.registerFactory(
    () => ClinicalBloc(manageClinicalUseCase: sl()),
  );

  // Profile Feature
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ManageProfileUseCase(sl()));
  sl.registerFactory(
    () => ProfileBloc(manageProfileUseCase: sl()),
  );
}
