// @dart=2.9
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/utils/navigation_helper.dart';
import 'package:frappe_app/views/form_view/form_view.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../model/doctype_response.dart';
import '../../services/api/api.dart';
import '../../utils/enums.dart';
import '../../utils/frappe_alert.dart';
import '../../utils/helpers.dart';
import '../../model/queue.dart';
import '../../views/base_viewmodel.dart';

@lazySingleton
class NewDocViewModel extends BaseViewModel {
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
        var qc = Queue.getQueueContainer();
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
        await Queue.add(qObj);

        FrappeAlert.infoAlert(
          title: 'No Internet Connection',
          subtitle: 'Added to Queue',
          context: context,
        );
        Navigator.of(context).pop();
      } else {
        try {
          var response = await locator<Api>().saveDocs(
            meta.docs[0].name,
            formValue,
          );
          NavigationHelper.pushReplacement(
            context: context,
            page: FormView(
              meta: meta,
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
