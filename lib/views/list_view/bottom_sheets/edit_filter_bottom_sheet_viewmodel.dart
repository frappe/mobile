import 'package:flutter/foundation.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class EditFilterBottomSheetViewModel extends BaseViewModel {
  var pageNumber = 1;
  var filter = [null, "Equals", ""];
  List<String> operators = [
    "Equals",
    "Not Equals",
    "Like",
    "Not Like",
    "In",
    "Not In",
    "Is"
  ];

  moveToPage(int _pageNumber) {
    pageNumber = _pageNumber;
    notifyListeners();
  }

  addFilterValue({
    @required int page,
    @required String value,
  }) {
    if (page == 1) {
      filter[0] = value;
    } else if (page == 2) {
      filter[1] = value;
    } else if (page == 3) {
      filter[2] = value;
    }
  }
}
