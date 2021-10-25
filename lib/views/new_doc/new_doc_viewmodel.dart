import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/utils/loading_indicator.dart';
import 'package:frappe_app/utils/navigation_helper.dart';
import 'package:frappe_app/views/form_view/form_view.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../model/doctype_response.dart';
import '../../services/api/api.dart';
import '../../utils/frappe_alert.dart';
import '../../utils/helpers.dart';
import '../../model/queue.dart';
import '../../views/base_viewmodel.dart';

@lazySingleton
class NewDocViewModel extends BaseViewModel {
  late Map newDoc;
  late List<DoctypeField> newDocFields;
  late DoctypeResponse meta;

  init() {
    newDocFields = meta.docs[0].fields.where(
      (field) {
        return field.hidden != 1 && field.fieldtype != "Column Break";
      },
    ).toList();

    newDoc = {};

    newDocFields.forEach((field) {
      var defaultVal = field.defaultValue;
      if (defaultVal == '__user') {
        defaultVal = Config().userId;
      }

      if (field.fieldtype == "Table") {
        defaultVal = [];
      }
      newDoc[field.fieldname] = defaultVal;
    });
  }

  saveDoc({
    required Map formValue,
    required DoctypeResponse meta,
    required BuildContext context,
  }) async {
    LoadingIndicator.loadingWithBackgroundDisabled('Saving');
    formValue.forEach(
      (key, value) {
        if (value is Uint8List) {
          formValue[key] = "data:image/png;base64,${base64.encode(value)}";
        }
      },
    );

    var isOnline = await verifyOnline();
    if (!isOnline) {
      // var qc = Queue.getQueueContainer();
      // var queueLength = qc.length;
      // var qObj = {
      //   "type": "Create",
      //   "doctype": meta.docs[0].name,
      //   "title": hasTitle(meta.docs[0])
      //       ? formValue[meta.docs[0].titleField] ??
      //           "${meta.docs[0].name} ${queueLength + 1}"
      //       : "${meta.docs[0].name} ${queueLength + 1}",
      //   "data": [formValue],
      // };
      // Queue.add(qObj);

      // FrappeAlert.infoAlert(
      //   title: 'No Internet Connection',
      //   subtitle: 'Added to Queue',
      //   context: context,
      // );
      // Navigator.of(context).pop();
      LoadingIndicator.stopLoading();
      throw ErrorResponse(
        statusCode: HttpStatus.serviceUnavailable,
      );
    } else {
      try {
        var response = await locator<Api>().saveDocs(
          meta.docs[0].name,
          formValue,
        );
        LoadingIndicator.stopLoading();
        NavigationHelper.pushReplacement(
          context: context,
          page: FormView(
            meta: meta.docs[0],
            name: response.data["docs"][0]["name"],
          ),
        );
      } catch (e) {
        LoadingIndicator.stopLoading();
        FrappeAlert.errorAlert(
          title: (e as ErrorResponse).statusMessage,
          context: context,
        );
      }
    }
  }
}
