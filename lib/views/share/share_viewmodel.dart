import 'package:auto_route/auto_route.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ShareViewModel extends BaseViewModel {
  final List<DoctypeField> fields = [
    DoctypeField(
      fieldname: 'read',
      fieldtype: 'Check',
      label: 'Can Read',
    ),
    DoctypeField(
      fieldname: 'write',
      fieldtype: 'Check',
      label: 'Can Write',
    ),
    DoctypeField(
      fieldname: 'share',
      fieldtype: 'Check',
      label: 'Can Share',
    ),
  ];

  var selectedUser;

  Map docInfo;

  updateDocInfo({
    @required String doctype,
    @required String name,
  }) async {
    docInfo = await locator<Api>().getDocinfo(
      doctype,
      name,
    );
    docInfo = docInfo["docinfo"];
    notifyListeners();
  }

  selectUser(String user) {
    selectedUser = user;
    notifyListeners();
  }

  share({Map data, String doctype, String name}) async {
    await locator<Api>().shareAdd(
      doctype,
      name,
      data,
    );

    selectedUser = null;

    await updateDocInfo(
      doctype: doctype,
      name: name,
    );
  }
}
