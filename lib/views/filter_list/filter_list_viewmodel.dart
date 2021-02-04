import 'package:injectable/injectable.dart';
import '../../model/doctype_response.dart';
import '../../views/base_viewmodel.dart';

@lazySingleton
class FilterListViewModel extends BaseViewModel {
  Map doc = {};
  List<DoctypeField> filterFields = [];

  getFieldsWithValue(
    List<DoctypeField> fields,
    Map filters,
  ) {
    var _doc = {};
    var standardFilterFields = fields.where((field) {
      return field.inStandardFilter == 1 || field.isDefaultFilter == 1;
    }).toList();

    standardFilterFields.add(DoctypeField(
      isDefaultFilter: 1,
      fieldname: "_assign",
      options: "User",
      label: "Assigned To",
      fieldtype: "Link",
    ));

    standardFilterFields.forEach(
      (field) {
        if (filters != null && filters.length > 0) {
          _doc[field.fieldname] = filters[field.fieldname];
        }
      },
    );

    doc = _doc;
    filterFields = standardFilterFields;
  }

  clearFields() {
    doc = {};
    notifyListeners();
  }
}
