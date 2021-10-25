import 'package:frappe_app/model/common.dart';

class Constants {
  static var offlinePageSize = 50;
  static var pageSize = 10;

  static var imageExtensions = ['jpg', 'jpeg'];

  static List<FilterOperator> filterOperators = [
    FilterOperator(label: "Like", value: "like"),
    FilterOperator(label: "Equals", value: "="),
    FilterOperator(label: "Not Equals", value: "!="),
    FilterOperator(label: "Not Like", value: "not like"),
    // FilterOperator(label: "In", value: "in"),
    // TODO
    // FilterOperator(label: "Not In", value: "not in"),
    FilterOperator(label: "Is", value: "is"),
  ];

  static var filterOperatorLabelMapping = {
    "like": "Like",
    "=": "Equals",
    "!=": "Not Equals",
    "not like": "Not Like",
    "is": "Is",
  };

  static var frappeFlutterDateFormatMapping = {
    "dd-mm-yyyy": "d-M-y",
    "yyyy-mm-dd": "y-M-d",
    "dd/mm/yyyy": "d/M/y",
    "dd.mm.yyyy": "d.M.y",
    "mm/dd/yyyy": "M/d/y",
    "mm-dd-yyyy": "M-d-y",
  };
}
