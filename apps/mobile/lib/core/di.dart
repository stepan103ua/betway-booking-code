import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../features/decode/data/datasources/booking_code_remote_data_source.dart';
import '../features/decode/data/repositories/booking_code_repository_impl.dart';
import '../features/decode/domain/repositories/booking_code_repository.dart';
import '../features/decode/presentation/cubit/popular_codes_cubit.dart';
import '../features/decode/presentation/cubit/slip_cubit.dart';
import 'network/dio_client.dart';

final getIt = GetIt.instance;

/// Registers every feature's dependency chain. `docs/mobile.md` §7: with one
/// feature this is more than a single
/// `BlocProvider(create: (_) => SlipCubit(RemoteBookingCodeRepository(dio)))`
/// strictly needs — it's here anyway because the ask is a scalable shape,
/// not the minimum code for today. Adding Create or Convert later is one
/// more block here, nothing above it changes.
void setupDependencies() {
  getIt.registerLazySingleton<Dio>(buildDioClient);

  getIt.registerLazySingleton<BookingCodeRemoteDataSource>(
    () => BookingCodeRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<BookingCodeRepository>(
    () => BookingCodeRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => SlipCubit(getIt()));
  getIt.registerFactory(() => PopularCodesCubit(getIt()));
}
