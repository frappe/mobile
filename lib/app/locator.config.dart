// @dart=2.9
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../services/connectivity_service.dart' as _i5;
import '../services/storage_service.dart' as _i15;
import '../views/desk/desk_viewmodel.dart' as _i6;
import '../views/form_view/bottom_sheets/assignees/assignees_bottom_sheet_viewmodel.dart'
    as _i4;
import '../views/form_view/bottom_sheets/attachments/add_attachments_bottom_sheet_viewmodel.dart'
    as _i3;
import '../views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_viewmodel.dart'
    as _i17;
import '../views/form_view/bottom_sheets/reviews/view_reviews_bottom_sheet_viewmodel.dart'
    as _i18;
import '../views/form_view/bottom_sheets/share/share_bottom_sheet_viewmodel.dart'
    as _i14;
import '../views/form_view/bottom_sheets/tags/tags_bottom_sheet_viewmodel.dart'
    as _i16;
import '../views/form_view/form_view_viewmodel.dart' as _i9;
import '../views/list_view/bottom_sheets/edit_filter_bottom_sheet_viewmodel.dart'
    as _i7;
import '../views/list_view/bottom_sheets/filters_bottom_sheet_viewmodel.dart'
    as _i8;
import '../views/list_view/list_view_viewmodel.dart' as _i10;
import '../views/login/login_viewmodel.dart' as _i11;
import '../views/new_doc/new_doc_viewmodel.dart'
    as _i13; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String environment, _i2.EnvironmentFilter environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.lazySingleton<_i3.AddAttachmentsBottomSheetViewModel>(
      () => _i3.AddAttachmentsBottomSheetViewModel());
  gh.lazySingleton<_i4.AssigneesBottomSheetViewModel>(
      () => _i4.AssigneesBottomSheetViewModel());
  gh.lazySingleton<_i5.ConnectivityService>(() => _i5.ConnectivityService());
  gh.lazySingleton<_i6.DeskViewModel>(() => _i6.DeskViewModel());
  gh.lazySingleton<_i7.EditFilterBottomSheetViewModel>(
      () => _i7.EditFilterBottomSheetViewModel());
  gh.lazySingleton<_i8.FiltersBottomSheetViewModel>(
      () => _i8.FiltersBottomSheetViewModel());
  gh.lazySingleton<_i9.FormViewViewModel>(() => _i9.FormViewViewModel());
  gh.lazySingleton<_i10.ListViewViewModel>(() => _i10.ListViewViewModel());
  gh.lazySingleton<_i11.LoginViewModel>(() => _i11.LoginViewModel());
  gh.lazySingleton<_i13.NewDocViewModel>(() => _i13.NewDocViewModel());
  gh.lazySingleton<_i14.ShareBottomSheetViewModel>(
      () => _i14.ShareBottomSheetViewModel());
  gh.lazySingleton<_i15.StorageService>(() => _i15.StorageService());
  gh.lazySingleton<_i16.TagsBottomSheetViewModel>(
      () => _i16.TagsBottomSheetViewModel());
  gh.lazySingleton<_i17.ViewAttachmenetsBottomSheetViewModel>(
      () => _i17.ViewAttachmenetsBottomSheetViewModel());
  gh.lazySingleton<_i18.ViewReviewsBottomSheetViewModel>(
      () => _i18.ViewReviewsBottomSheetViewModel());
  return get;
}
