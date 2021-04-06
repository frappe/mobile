import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FiltersBottomSheetViewModel extends BaseViewModel {
  var filtersToApply = [];

  removeFilter(int index) {
    filtersToApply.removeAt(index);
    notifyListeners();
  }

  clearFilters() {
    filtersToApply.clear();
    notifyListeners();
  }

  addFilter() {
    filtersToApply.add(
      [
        null,
        "Equals",
        "",
      ],
    );
    notifyListeners();
  }
}
