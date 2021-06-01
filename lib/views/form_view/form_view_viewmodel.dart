import 'dart:io';

import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/utils/loading_indicator.dart';
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
  String? name;
  late DoctypeResponse meta;
  late bool queued;
  Map? queuedData;

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

  Future getData() async {
    setState(ViewState.busy);
    if (queued && queuedData != null) {
      formData = GetDocResponse(
        docs: queuedData!["data"],
      );
    } else {
      try {
        var isOnline = await verifyOnline();
        var doctype = meta.docs[0].name;

        if (!isOnline) {
          var response = OfflineStorage.getItem(
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
      } catch (e) {
        error = e as ErrorResponse;
      }
    }
    setState(ViewState.idle);
  }

  getDocinfo() async {
    docinfo = await locator<Api>().getDocinfo(meta.docs[0].name, name!);
    notifyListeners();
  }

  Future handleUpdate({
    required Map formValue,
    required Map doc,
    required Map? queuedData,
  }) async {
    LoadingIndicator.loadingWithBackgroundDisabled("Saving");
    var isOnline = await verifyOnline();
    if (!isOnline) {
      // if (queuedData != null) {
      //   queuedData["data"] = [
      //     {
      //       ...doc,
      //       ...formValue,
      //     }
      //   ];
      //   queuedData["updated_keys"] = {
      //     ...queuedData["updated_keys"],
      //     ...extractChangedValues(
      //       doc,
      //       formValue,
      //     )
      //   };
      //   queuedData["title"] = getTitle(
      //     meta.docs[0],
      //     formValue,
      //   );

      //   Queue.putAt(
      //     queuedData["qIdx"],
      //     queuedData,
      //   );
      // } else {
      //   Queue.add(
      //     {
      //       "type": "Update",
      //       "name": name,
      //       "doctype": meta.docs[0].name,
      //       "title": getTitle(meta.docs[0], formValue),
      //       "updated_keys": extractChangedValues(doc, formValue),
      //       "data": [
      //         {
      //           ...doc,
      //           ...formValue,
      //         }
      //       ],
      //     },
      //   );
      // }
      LoadingIndicator.stopLoading();
      throw ErrorResponse(
        statusCode: HttpStatus.serviceUnavailable,
      );
    } else {
      formValue = {
        ...doc,
        ...formValue,
      };

      try {
        var response = await locator<Api>().saveDocs(
          meta.docs[0].name,
          formValue,
        );

        if (response.statusCode == HttpStatus.ok) {
          docinfo = Docinfo.fromJson(
            response.data["docinfo"],
          );
          formData = GetDocResponse(
            docs: response.data["docs"],
            docinfo: docinfo,
          );

          LoadingIndicator.stopLoading();

          refresh();
        }
      } catch (e) {
        LoadingIndicator.stopLoading();
        throw e;
      }
    }
  }
}
