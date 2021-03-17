import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ShareBottomSheetViewModel extends BaseViewModel {
  var currentShares = [];
  var newShares = [];
  var permissionLevels = [
    "Can Read",
    "Can Write",
    "Can Share",
    "Full Access",
  ];
  var currentPermission = "Can Read";

  addShare() {}

  selectPermission(String permission) {
    currentPermission = permission;
    notifyListeners();
  }

  updateNewShares(List l) {
    newShares = l;
    notifyListeners();
  }

  updatePermission() {}
}
