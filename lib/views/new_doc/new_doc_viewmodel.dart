import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/app/router.gr.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/services/navigation_service.dart';
import 'package:frappe_app/utils/cache_helper.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/frappe_alert.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/utils/queue_helper.dart';

class NewDocViewModel {
  getData(String doctype) {
    return CacheHelper.getMeta(
      doctype,
    );
  }

  saveDoc({
    @required var formKey,
    @required var connectionStatus,
    @required DoctypeResponse meta,
    @required BuildContext context,
  }) async {
    if (formKey.currentState.saveAndValidate()) {
      var formValue = formKey.currentState.value;

      formValue.forEach((key, value) {
        if (value is Uint8List) {
          formValue[key] = "data:image/png;base64,${base64.encode(value)}";
        }
      });

      var isOnline = await verifyOnline();
      if ((connectionStatus == null ||
              connectionStatus == ConnectivityStatus.offline) &&
          !isOnline) {
        var qc = QueueHelper.getQueueContainer();
        var queueLength = qc.length;
        var qObj = {
          "type": "Create",
          "doctype": meta.docs[0].name,
          "title": hasTitle(meta.docs[0])
              ? formValue[meta.docs[0].titleField] ??
                  "${meta.docs[0].name} ${queueLength + 1}"
              : "${meta.docs[0].name} ${queueLength + 1}",
          "data": [formValue],
        };
        await QueueHelper.add(qObj);

        FrappeAlert.infoAlert(
          title: 'No Internet Connection',
          subtitle: 'Added to Queue',
          context: context,
        );
        locator<NavigationService>().pop();
      } else {
        try {
          var response = await locator<Api>().saveDocs(
            meta.docs[0].name,
            formValue,
          );
          locator<NavigationService>().pushReplacement(
            Routes.formView,
            arguments: FormViewArguments(
              doctype: meta.docs[0].name,
              name: response.data["docs"][0]["name"],
            ),
          );
        } catch (e) {
          showErrorDialog(e, context);
        }
      }
    }
  }
}
