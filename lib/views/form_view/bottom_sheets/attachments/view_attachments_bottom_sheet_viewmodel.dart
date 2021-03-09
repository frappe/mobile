import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ViewAttachmenetsBottomSheetViewModel extends BaseViewModel {
  AttachmentsFilter selectedFilter = AttachmentsFilter.all;

  changeTab(AttachmentsFilter tab) {
    selectedFilter = tab;
    notifyListeners();
  }
}
