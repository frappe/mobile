// @dart=2.9
import 'package:flutter/foundation.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TagsBottomSheetViewModel extends BaseViewModel {
  var currentTags = [];

  addTag({
    @required String doctype,
    @required String name,
    @required String tag,
  }) async {
    var addedTag = await locator<Api>().addTag(
      doctype,
      name,
      tag,
    );

    currentTags.insert(0, addedTag["message"]);

    notifyListeners();
  }

  removeTag({
    @required String doctype,
    @required String name,
    @required String tag,
    @required int index,
  }) async {
    await locator<Api>().removeTag(
      doctype,
      name,
      tag,
    );

    currentTags.removeAt(index);

    notifyListeners();
  }

  getTags({
    @required String query,
    @required String doctype,
  }) async {
    var lowercaseQuery = query.toLowerCase();
    var response = await locator<Api>().getTags(
      doctype,
      lowercaseQuery,
    );

    return response["message"];
  }
}
