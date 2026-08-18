import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:goldz/core/cashe/hive_boxes.dart';
import 'package:goldz/core/settings/settings_cubit.dart';
import 'package:goldz/features/gold_prices/data/repositories/market_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/guest_sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/gold_prices/data/datasources/market_local_datasource.dart';
import '../../features/gold_prices/data/datasources/market_remote_datasource.dart';
import '../../features/gold_prices/data/repositories/market_repository_impl.dart';
import '../../features/gold_prices/domain/usecases/get_market_snapshot.dart';
import '../../features/gold_prices/presentation/cubit/market_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //──────────── External ────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<Dio>(() => DioClient.create().dio);
  sl.registerLazySingleton<Box>(() => Hive.box(HiveBoxes.market));

  //──────────── Core ────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //──────────── Auth ────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => GuestSignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      signUpUseCase: sl(),
      signInUseCase: sl(),
      guestSignInUseCase: sl(),
      signOutUseCase: sl(),
      repository: sl(),
    ),
  );

  //──────────── Market ────────────
  sl.registerLazySingleton<MarketRemoteDataSource>(
    () => MarketRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MarketLocalDataSource>(
    () => MarketLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(
      remote: sl(),
      local: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetMarketSnapshot(sl()));
  sl.registerFactory(() => MarketCubit(sl()));
  sl.registerLazySingleton(() => SettingsCubit(sl()));
}
