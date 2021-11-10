// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../services/connectivity_service.dart' as _i7;
import '../services/storage_service.dart' as _i17;
import '../views/awesome_bar/awesome_bar_viewmodel.dart' as _i6;
import '../views/desk/desk_viewmodel.dart' as _i8;
import '../views/form_view/bottom_sheets/assignees/assignees_bottom_sheet_viewmodel.dart'
    as _i5;
import '../views/form_view/bottom_sheets/attachments/add_attachments_bottom_sheet_viewmodel.dart'
    as _i3;
import '../views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_viewmodel.dart'
    as _i19;
import '../views/form_view/bottom_sheets/reviews/add_review_bottom_sheet_viewmodel.dart'
    as _i4;
import '../views/form_view/bottom_sheets/reviews/view_reviews_bottom_sheet_viewmodel.dart'
    as _i20;
import '../views/form_view/bottom_sheets/share/share_bottom_sheet_viewmodel.dart'
    as _i15;
import '../views/form_view/bottom_sheets/tags/tags_bottom_sheet_viewmodel.dart'
    as _i18;
import '../views/list_view/bottom_sheets/edit_filter_bottom_sheet_viewmodel.dart'
    as _i9;
import '../views/list_view/bottom_sheets/filters_bottom_sheet_viewmodel.dart'
    as _i10;
import '../views/list_view/bottom_sheets/sort_by_fields_bottom_sheet_viewmodel.dart'
    as _i16;
import '../views/list_view/list_view_viewmodel.dart' as _i11;
import '../views/login/login_viewmodel.dart' as _i12;
import '../views/new_doc/new_doc_viewmodel.dart' as _i13;
import '../views/send_email/send_email_viewmodel.dart'
    as _i14; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.lazySingleton<_i3.AddAttachmentsBottomSheetViewModel>(
      () => _i3.AddAttachmentsBottomSheetViewModel());
  gh.lazySingleton<_i4.AddReviewBottomSheetViewModel>(
      () => _i4.AddReviewBottomSheetViewModel());
  gh.lazySingleton<_i5.AssigneesBottomSheetViewModel>(
      () => _i5.AssigneesBottomSheetViewModel());
  gh.lazySingleton<_i6.AwesomBarViewModel>(() => _i6.AwesomBarViewModel());
  gh.lazySingleton<_i7.ConnectivityService>(() => _i7.ConnectivityService());
  gh.lazySingleton<_i8.DeskViewModel>(() => _i8.DeskViewModel());
  gh.lazySingleton<_i9.EditFilterBottomSheetViewModel>(
      () => _i9.EditFilterBottomSheetViewModel());
  gh.lazySingleton<_i10.FiltersBottomSheetViewModel>(
      () => _i10.FiltersBottomSheetViewModel());
  gh.lazySingleton<_i11.ListViewViewModel>(() => _i11.ListViewViewModel());
  gh.lazySingleton<_i12.LoginViewModel>(() => _i12.LoginViewModel());
  gh.lazySingleton<_i13.NewDocViewModel>(() => _i13.NewDocViewModel());
  gh.lazySingleton<_i14.SendEmailViewModel>(() => _i14.SendEmailViewModel());
  gh.lazySingleton<_i15.ShareBottomSheetViewModel>(
      () => _i15.ShareBottomSheetViewModel());
  gh.lazySingleton<_i16.SortByFieldsBottomSheetViewModel>(
      () => _i16.SortByFieldsBottomSheetViewModel());
  gh.lazySingleton<_i17.StorageService>(() => _i17.StorageService());
  gh.lazySingleton<_i18.TagsBottomSheetViewModel>(
      () => _i18.TagsBottomSheetViewModel());
  gh.lazySingleton<_i19.ViewAttachmenetsBottomSheetViewModel>(
      () => _i19.ViewAttachmenetsBottomSheetViewModel());
  gh.lazySingleton<_i20.ViewReviewsBottomSheetViewModel>(
      () => _i20.ViewReviewsBottomSheetViewModel());
  return get;
}
