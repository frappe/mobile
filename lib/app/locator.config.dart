// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../views/add_assignees/add_assignees_viewmodel.dart';
import '../views/form_view/bottom_sheets/attachments/add_attachments_bottom_sheet_viewmodel.dart';
import '../views/add_review/add_review_viewmodel.dart';
import '../views/add_tags/add_tags_viewmodel.dart';
import '../views/form_view/bottom_sheets/assignees/assignees_bottom_sheet_viewmodel.dart';
import '../services/connectivity_service.dart';
import '../views/desk/desk_viewmodel.dart';
import '../views/list_view/bottom_sheets/edit_filter_bottom_sheet_viewmodel.dart';
import '../views/filter_list/filter_list_viewmodel.dart';
import '../views/list_view/bottom_sheets/filters_bottom_sheet_viewmodel.dart';
import '../views/form_view/form_view_viewmodel.dart';
import '../views/list_view/list_view_viewmodel.dart';
import '../views/login/login_viewmodel.dart';
import '../services/navigation_service.dart';
import '../views/new_doc/new_doc_viewmodel.dart';
import '../views/form_view/bottom_sheets/share/share_bottom_sheet_viewmodel.dart';
import '../views/share/share_viewmodel.dart';
import '../services/storage_service.dart';
import '../views/form_view/bottom_sheets/tags/tags_bottom_sheet_viewmodel.dart';
import '../views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_viewmodel.dart';
import '../views/form_view/bottom_sheets/reviews/view_reviews_bottom_sheet_viewmodel.dart';

/// adds generated dependencies
/// to the provided [GetIt] instance

GetIt $initGetIt(
  GetIt get, {
  String environment,
  EnvironmentFilter environmentFilter,
}) {
  final gh = GetItHelper(get, environment, environmentFilter);
  gh.lazySingleton<AddAssigneesViewModel>(() => AddAssigneesViewModel());
  gh.lazySingleton<AddAttachmentsBottomSheetViewModel>(
      () => AddAttachmentsBottomSheetViewModel());
  gh.lazySingleton<AddReviewViewModel>(() => AddReviewViewModel());
  gh.lazySingleton<AddTagsViewModel>(() => AddTagsViewModel());
  gh.lazySingleton<AssigneesBottomSheetViewModel>(
      () => AssigneesBottomSheetViewModel());
  gh.lazySingleton<ConnectivityService>(() => ConnectivityService());
  gh.lazySingleton<DeskViewModel>(() => DeskViewModel());
  gh.lazySingleton<EditFilterBottomSheetViewModel>(
      () => EditFilterBottomSheetViewModel());
  gh.lazySingleton<FilterListViewModel>(() => FilterListViewModel());
  gh.lazySingleton<FiltersBottomSheetViewModel>(
      () => FiltersBottomSheetViewModel());
  gh.lazySingleton<FormViewViewModel>(() => FormViewViewModel());
  gh.lazySingleton<ListViewViewModel>(() => ListViewViewModel());
  gh.lazySingleton<LoginViewModel>(() => LoginViewModel());
  gh.lazySingleton<NavigationService>(() => NavigationService());
  gh.lazySingleton<NewDocViewModel>(() => NewDocViewModel());
  gh.lazySingleton<ShareBottomSheetViewModel>(
      () => ShareBottomSheetViewModel());
  gh.lazySingleton<ShareViewModel>(() => ShareViewModel());
  gh.lazySingleton<StorageService>(() => StorageService());
  gh.lazySingleton<TagsBottomSheetViewModel>(() => TagsBottomSheetViewModel());
  gh.lazySingleton<ViewAttachmenetsBottomSheetViewModel>(
      () => ViewAttachmenetsBottomSheetViewModel());
  gh.lazySingleton<ViewReviewsBottomSheetViewModel>(
      () => ViewReviewsBottomSheetViewModel());
  return get;
}
