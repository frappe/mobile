import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frappe_app/model/common.dart';

import 'package:frappe_app/utils/frappe_alert.dart';
import 'package:frappe_app/views/form_view/form_view.dart';
import 'package:frappe_app/views/list_view/list_view.dart';
import 'package:injectable/injectable.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../views/base_viewmodel.dart';

import '../../model/desk_sidebar_items_response.dart';
import '../../model/desktop_page_response.dart';
import '../../model/offline_storage.dart';

import '../../utils/enums.dart';
import '../../utils/helpers.dart';

@lazySingleton
class DeskViewModel extends BaseViewModel {
  late String currentModule;
  List<DeskMessage> modules = [];
  late DesktopPageResponse desktopPage;
  ErrorResponse? error;

  switchModule(
    String newModule,
  ) async {
    currentModule = newModule;
    await getDesktopPage(
      currentModule,
    );
    notifyListeners();
  }

  bool get hasError => error != null;

  Future getDeskSidebarItems() async {
    DeskSidebarItemsResponse deskSidebarItems;

    var isOnline = await verifyOnline();

    if (!isOnline) {
      var deskSidebarItemsCache =
          OfflineStorage.getItem('deskSidebarItems')["data"];

      if (deskSidebarItemsCache != null) {
        deskSidebarItems =
            DeskSidebarItemsResponse.fromJson(deskSidebarItemsCache);
      } else {
        throw ErrorResponse(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      try {
        deskSidebarItems = await locator<Api>().getDeskSideBarItems();
      } catch (e) {
        throw e as ErrorResponse;
      }
    }

    modules = deskSidebarItems.message;
  }

  getDesktopPage(
    String currentModule,
  ) async {
    DesktopPageResponse _desktopPage;

    var isOnline = await verifyOnline();

    if (!isOnline) {
      var moduleDoctypes =
          OfflineStorage.getItem('${currentModule}Doctypes')["data"];

      if (moduleDoctypes != null) {
        _desktopPage = DesktopPageResponse.fromJson(moduleDoctypes);
      } else {
        throw ErrorResponse(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      try {
        _desktopPage = await locator<Api>().getDesktopPage(currentModule);
      } catch (e) {
        throw e as ErrorResponse;
      }
    }

    desktopPage = _desktopPage;
  }

  getData() async {
    setState(ViewState.busy);
    try {
      await getDeskSidebarItems();

      currentModule = modules[0].label;

      await getDesktopPage(
        currentModule,
      );
      error = null;
    } catch (e) {
      error = e as ErrorResponse;
    }
    setState(ViewState.idle);
  }

  navigateToView({
    required String doctype,
    required BuildContext context,
  }) async {
    try {
      var meta = await OfflineStorage.getMeta(doctype);

      if (meta.docs[0].issingle == 1) {
        pushNewScreen(
          context,
          screen: FormView(
            meta: meta,
            name: meta.docs[0].name,
          ),
          withNavBar: true,
        );
      } else {
        pushNewScreen(
          context,
          screen: CustomListView(
            meta: meta,
          ),
          withNavBar: true,
        );
      }
    } catch (e) {
      FrappeAlert.errorAlert(
        context: context,
        title: e is ErrorResponse ? e.statusMessage : "Something went wrong",
      );
    }
  }
}
