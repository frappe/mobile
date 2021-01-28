import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../views/base_viewmodel.dart';

@lazySingleton
class AddTagsViewModel extends BaseViewModel {
  var newTags = [];

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

    newTags.insert(0, addedTag["message"]);

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

  removeTag({
    @required int idx,
    @required String doctype,
    @required String name,
    @required String tag,
  }) {
    newTags.removeAt(idx);
    locator<Api>().removeTag(
      doctype,
      name,
      tag,
    );
    notifyListeners();
  }
}
