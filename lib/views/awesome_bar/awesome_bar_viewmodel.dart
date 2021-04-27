import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AwesomBarViewModel extends BaseViewModel {
  bool hasFocus = false;

  toggleFocus(bool _hasFocus) {
    hasFocus = _hasFocus;
    notifyListeners();
  }
}
