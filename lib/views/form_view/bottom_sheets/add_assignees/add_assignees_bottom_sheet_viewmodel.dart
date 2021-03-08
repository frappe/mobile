import 'package:flutter/foundation.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/services/navigation_service.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AddAssigneesBottomSheetViewModel extends BaseViewModel {
  List<String> selectedUsers = [];

  onUserSelected(String user) {
    selectedUsers.add(user);
    notifyListeners();
  }

  addAssignees({
    @required String doctype,
    @required String name,
  }) async {
    await locator<Api>().addAssignees(
      doctype,
      name,
      selectedUsers,
    );
    locator<NavigationService>().pop(true);
  }

  removeUser(int index) {
    selectedUsers.removeAt(index);
    notifyListeners();
  }
}
