import 'package:flutter/material.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/constants.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FiltersBottomSheetViewModel extends BaseViewModel {
  List<Filter> filtersToApply = [];
  late List<DoctypeField> fields;

  removeFilter(int index) {
    filtersToApply.removeAt(index);
    notifyListeners();
  }

  updateFilter({
    required Filter filter,
    required int index,
  }) {
    filtersToApply[index] = filter;
    notifyListeners();
  }

  clearFilters() {
    filtersToApply.clear();
    notifyListeners();
  }

  addFilter() {
    filtersToApply.add(
      Filter(
        filterOperator: Constants.filterOperators[0],
        field: fields[0],
        isInit: true,
      ),
    );
    notifyListeners();
  }
}
