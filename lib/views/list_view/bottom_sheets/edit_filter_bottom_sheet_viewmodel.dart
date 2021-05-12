// @dart=2.9
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';
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

  updateFieldName(DoctypeField field) {
    filter.field = field;
    filter.value = null;
    notifyListeners();
  }

  updateFilterOperator(FilterOperator filterOperator) {
    filter.filterOperator = filterOperator;
    notifyListeners();
  }

  updateValue(String value) {
    filter.value = value;
    filter.isInit = false;
  }
}
