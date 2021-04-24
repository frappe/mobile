import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../model/doctype_response.dart';
import '../../views/base_viewmodel.dart';
import '../../services/api/api.dart';

import '../../model/offline_storage.dart';
import '../../model/config.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';
import '../../model/queue.dart';

@lazySingleton
class FormViewViewModel extends BaseViewModel {
  late bool editMode;
  ErrorResponse? error;
  late GetDocResponse formData;
  final user = Config().user;
  Docinfo? docinfo;
  late bool communicationOnly;

  void refresh() {
    editMode = false;
    notifyListeners();
  }

  toggleSwitch(bool newVal) {
    communicationOnly = newVal;
    notifyListeners();
  }

  void toggleEdit() {
    editMode = !editMode;

    notifyListeners();
  }

  Future getData({
    required bool queued,
    required String doctype,
    required String? name,
    required Map? queuedData,
    required ConnectivityStatus connectivityStatus,
  }) async {
    setState(ViewState.busy);
    if (queued && queuedData != null) {
      formData = GetDocResponse(
        docs: queuedData["data"],
      );
    } else {
      var isOnline = await verifyOnline();

      if (!isOnline) {
        var response = await OfflineStorage.getItem(
          '$doctype$name',
        );
        response = response["data"];
        if (response != null) {
          formData = GetDocResponse.fromJson(response);
          docinfo = formData.docinfo;
        } else {
          error = ErrorResponse(
            statusCode: HttpStatus.serviceUnavailable,
          );
        }
      } else {
        formData = await locator<Api>().getdoc(
          doctype,
          name!,
        );
        docinfo = formData.docinfo;
      }
    }
    setState(ViewState.idle);
  }

  updateDocinfo({required String name, required String doctype}) async {
    docinfo = await locator<Api>().getDocinfo(doctype, name);
    notifyListeners();
  }

  Future handleUpdate({
    required String name,
    required String doctype,
    required DoctypeResponse meta,
    required Map formValue,
    required ConnectivityStatus connectivityStatus,
    required Map doc,
    required Map? queuedData,
  }) async {
    formValue.forEach((key, value) {
      if (value is Uint8List) {
        var str = base64.encode(value);

        formValue[key] = "data:image/png;base64,$str";
      }
    });
    var isOnline = await verifyOnline();
    if (connectivityStatus == ConnectivityStatus.offline && !isOnline) {
      if (queuedData != null) {
        queuedData["data"] = [
          {
            ...doc,
            ...formValue,
          }
        ];
        queuedData["updated_keys"] = {
          ...queuedData["updated_keys"],
          ...extractChangedValues(
            doc,
            formValue,
          )
        };
        queuedData["title"] = getTitle(
          meta.docs[0],
          formValue,
        );

        Queue.putAt(
          queuedData["qIdx"],
          queuedData,
        );
      } else {
        Queue.add({
          "type": "Update",
          "name": name,
          "doctype": doctype,
          "title": getTitle(meta.docs[0], formValue),
          "updated_keys": extractChangedValues(doc, formValue),
          "data": [
            {
              ...doc,
              ...formValue,
            }
          ],
        });
      }
    } else {
      formValue = {
        ...doc,
        ...formValue,
      };

      try {
        var response = await locator<Api>().saveDocs(
          doctype,
          formValue,
        );

        if (response.statusCode == HttpStatus.ok) {
          refresh();
        }
      } catch (e) {
        throw e;
      }
    }
  }
}
