// @dart=2.9
import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ShareBottomSheetViewModel extends BaseViewModel {
  List<Shared> currentShares = [];
  var shareWithUsers = [];
  var permissionLevels = [
    "Can Read",
    "Can Write",
    "Can Share",
    "Full Access",
  ];
  var currentPermission = "Can Read";

  addShare({
    @required String doctype,
    @required String name,
    @required String permission,
    @required List users,
  }) async {
    for (var user in users) {
      var permissions = {
        "read": 1,
        "user": user["value"],
      };

      if (permission == "Can Write") {
        permissions["write"] = 1;
      } else if (permission == "Can Share") {
        permissions["share"] = 1;
      } else if (permission == "Full Access") {
        permissions["share"] = 1;
        permissions["write"] = 1;
      }

      var response = await locator<Api>().shareAdd(
        doctype,
        name,
        permissions,
      );

      currentShares.insert(0, response["message"]);
      notifyListeners();
    }
  }

  selectPermission(String permission) {
    currentPermission = permission;
    notifyListeners();
  }

  updateNewShares(List l) {
    shareWithUsers = l;
    notifyListeners();
  }

  updatePermission({
    @required String doctype,
    @required String name,
    @required String newPermission,
    @required String currentPermission,
    @required String user,
  }) async {
    var reqs = [];
    if (currentPermission == "Can Write") {
      reqs.add(
        {
          "permission_to": "write",
          "value": 0,
        },
      );
    } else if (currentPermission == "Can Share") {
      reqs.add(
        {
          "permission_to": "share",
          "value": 0,
        },
      );
    } else if (currentPermission == "Full Access") {
      reqs.addAll(
        [
          {
            "permission_to": "share",
            "value": 0,
          },
          {
            "permission_to": "write",
            "value": 0,
          },
        ],
      );
    }

    if (newPermission == "Can Write") {
      reqs.add(
        {
          "permission_to": "write",
          "value": 1,
        },
      );
    } else if (newPermission == "Can Share") {
      reqs.add(
        {
          "permission_to": "share",
          "value": 1,
        },
      );
    } else if (newPermission == "Full Access") {
      reqs.addAll(
        [
          {
            "permission_to": "share",
            "value": 1,
          },
          {
            "permission_to": "write",
            "value": 1,
          },
        ],
      );
    }

    for (var req in reqs) {
      await locator<Api>().setPermission(
        doctype: doctype,
        name: name,
        shareInfo: req,
        user: user,
      );
    }

    var response = await locator<Api>().shareGetUsers(
      doctype: doctype,
      name: name,
    );
    currentShares = response["message"];

    notifyListeners();
  }
}
