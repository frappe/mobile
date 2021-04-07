import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class EditFilterBottomSheetViewModel extends BaseViewModel {
  var pageNumber = 1;
  Filter filter;

  moveToPage(int _pageNumber) {
    pageNumber = _pageNumber;
    notifyListeners();
  }

  updateFieldName(String fieldName) {
    filter.fieldname = fieldName;
  }

  updateFilterOperator(FilterOperator filterOperator) {
    filter.filterOperator = filterOperator;
  }

  updateValue(String value) {
    filter.value = value;
  }
}
