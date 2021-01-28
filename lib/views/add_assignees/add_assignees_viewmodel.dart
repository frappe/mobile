import 'package:injectable/injectable.dart';
import '../../views/base_viewmodel.dart';

@lazySingleton
class AddAssigneesViewModel extends BaseViewModel {
  var newAssignees = [];

  selectUser(String user) {
    newAssignees.add(user);
    notifyListeners();
  }
}
