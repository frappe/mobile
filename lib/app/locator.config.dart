// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../views/add_assignees/add_assignees_viewmodel.dart';
import '../views/add_review/add_review_viewmodel.dart';
import '../views/add_tags/add_tags_viewmodel.dart';
import '../services/connectivity_service.dart';
import '../views/filter_list/filter_list_viewmodel.dart';
import '../views/form_view/form_view_viewmodel.dart';
import '../views/home/home_viewmodel.dart';
import '../views/list_view/list_view_viewmodel.dart';
import '../views/login/login_viewmodel.dart';
import '../services/navigation_service.dart';
import '../views/new_doc/new_doc_viewmodel.dart';
import '../views/share/share_viewmodel.dart';
import '../services/storage_service.dart';

/// adds generated dependencies
/// to the provided [GetIt] instance

GetIt $initGetIt(
  GetIt get, {
  String environment,
  EnvironmentFilter environmentFilter,
}) {
  final gh = GetItHelper(get, environment, environmentFilter);
  gh.lazySingleton<AddAssigneesViewModel>(() => AddAssigneesViewModel());
  gh.lazySingleton<AddReviewViewModel>(() => AddReviewViewModel());
  gh.lazySingleton<AddTagsViewModel>(() => AddTagsViewModel());
  gh.lazySingleton<ConnectivityService>(() => ConnectivityService());
  gh.lazySingleton<FilterListViewModel>(() => FilterListViewModel());
  gh.lazySingleton<FormViewViewModel>(() => FormViewViewModel());
  gh.lazySingleton<HomeViewModel>(() => HomeViewModel());
  gh.lazySingleton<ListViewViewModel>(() => ListViewViewModel());
  gh.lazySingleton<LoginViewModel>(() => LoginViewModel());
  gh.lazySingleton<NavigationService>(() => NavigationService());
  gh.lazySingleton<NewDocViewModel>(() => NewDocViewModel());
  gh.lazySingleton<ShareViewModel>(() => ShareViewModel());
  gh.lazySingleton<StorageService>(() => StorageService());
  return get;
}
