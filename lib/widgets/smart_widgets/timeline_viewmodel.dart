import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TimelineViewModel extends BaseViewModel {
  bool communicationOnly;
  Docinfo docinfo;
  List events;
  String doctype;
  String name;

  processData() {
    var _events = [
      ...docinfo.comments.map(
        (comment) {
          var c = comment.toJson();
          c["_category"] = "comments";
          return c;
        },
      ).toList(),
      ...docinfo.communications.map((communication) {
        var c = communication.toJson();
        c["_category"] = "communications";
        return c;
      }).toList(),
      ...docinfo.versions.map((version) {
        var v = version.toJson();
        v["_category"] = "versions";
        return v;
      }).toList(),
      ...docinfo.views.map((view) {
        var v = view.toJson();
        v["_category"] = "views";
        return v;
      }).toList(),
    ];
    events = sortBy(_events, "creation", Order.desc);
  }

  toggleSwitch(bool newVal) {
    communicationOnly = newVal;
    notifyListeners();
  }

  refreshDocinfo() async {
    docinfo = await locator<Api>().getDocinfo(
      doctype,
      name,
    );

    processData();

    notifyListeners();
  }
}
