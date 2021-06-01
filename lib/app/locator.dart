import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'locator.config.dart';

import '../services/api/api.dart';
import '../services/api/dio_api.dart';
// import '../services/api/fake_api.dart';

final locator = GetIt.instance;

const bool USE_FAKE_IMPLEMENTATION = false;

@injectableInit
void setupLocator() {
  // locator.registerLazySingleton<Api>(
  //   () => USE_FAKE_IMPLEMENTATION ? FakeApi() : DioApi(),
  // );
  locator.registerLazySingleton<Api>(
    () => DioApi(),
  );
  $initGetIt(locator);
}
