import 'dart:io';

import 'package:dio/dio.dart';

import '../filter_list/filter_list_view.dart';
import '../../app/locator.dart';
import '../../services/api/api.dart';

import '../../utils/cache_helper.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';

class ActivateModulesViewModel {
  Future getData(ConnectivityStatus connectionStatus) async {
    var isOnline = await verifyOnline();
    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var response = await CacheHelper.getCache('DocTypeList');
      response = response["data"];
      if (response == null) {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
      return response;
    } else {
      var meta = await locator<Api>().getDoctype('Doctype');
      var doctypeDoc = meta.docs[0];
      var deskSideBarItems = await locator<Api>().getDeskSideBarItems();
      var deskModules = deskSideBarItems.message.where((item) {
        return item.category == "Modules";
      }).toList();

      var doctypes = await locator<Api>().fetchList(
        fieldnames: [
          "`tabDocType`.`name`",
          "`tabDocType`.`module`",
        ],
        doctype: 'DocType',
        meta: doctypeDoc,
        filters: FilterList.generateFilters(
          'DocType',
          {
            "istable": 0,
            "issingle": 0,
          },
        ),
      );

      doctypes.forEach((doctype) {
        var deskModule = deskModules.firstWhere(
          (deskModule) => doctype["module"] == deskModule.module,
          orElse: () => null,
        );

        if (deskModule != null) {
          doctype["module_label"] = deskModule.label;
        } else {
          doctype["module_label"] = doctype["module"];
        }
      });

      return doctypes;
    }
  }
}
