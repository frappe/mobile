// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../services/connectivity_service.dart';
import '../views/home/home_viewmodel.dart';
import '../views/list_view/list_view_viewmodel.dart';
import '../views/login/login_viewmodel.dart';
import '../services/navigation_service.dart';
import '../services/storage_service.dart';

/// adds generated dependencies
/// to the provided [GetIt] instance

GetIt $initGetIt(
  GetIt get, {
  String environment,
  EnvironmentFilter environmentFilter,
}) {
  final gh = GetItHelper(get, environment, environmentFilter);
  gh.lazySingleton<ConnectivityService>(() => ConnectivityService());
  gh.lazySingleton<HomeViewModel>(() => HomeViewModel());
  gh.lazySingleton<ListViewViewModel>(() => ListViewViewModel());
  gh.lazySingleton<LoginViewModel>(() => LoginViewModel());
  gh.lazySingleton<NavigationService>(() => NavigationService());
  gh.lazySingleton<StorageService>(() => StorageService());
  return get;
}
