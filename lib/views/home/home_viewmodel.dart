import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/model/desk_sidebar_items_response.dart';
import 'package:frappe_app/model/desktop_page_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/utils/config_helper.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HomeViewModel extends BaseViewModel {
  String currentModule;
  List<DeskMessage> modules = [];
  DesktopPageResponse desktopPage;

  refresh(ConnectivityStatus connectivityStatus) async {
    getData(connectivityStatus);
  }

  switchModule({
    @required String newModule,
    @required ConnectivityStatus connectivityStatus,
  }) async {
    currentModule = newModule;
    await getDesktopPage(
      connectionStatus: connectivityStatus,
      currentModule: currentModule,
    );
    notifyListeners();
  }

  Future getDeskSidebarItems(ConnectivityStatus connectionStatus) async {
    DeskSidebarItemsResponse deskSidebarItems;

    var isOnline = await verifyOnline();

    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var deskSidebarItemsCache =
          await OfflineStorage.getItem('deskSidebarItems');
      deskSidebarItemsCache = deskSidebarItemsCache["data"];

      if (deskSidebarItemsCache != null) {
        deskSidebarItems =
            DeskSidebarItemsResponse.fromJson(deskSidebarItemsCache);
      } else {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      deskSidebarItems = await locator<Api>().getDeskSideBarItems();
    }

    modules = deskSidebarItems.message;
  }

  getDesktopPage({
    @required ConnectivityStatus connectionStatus,
    @required String currentModule,
  }) async {
    DesktopPageResponse _desktopPage;

    var isOnline = await verifyOnline();

    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var moduleDoctypes = OfflineStorage.getItem('${currentModule}Doctypes');
      moduleDoctypes = moduleDoctypes["data"];

      if (moduleDoctypes != null) {
        _desktopPage = DesktopPageResponse.fromJson(moduleDoctypes);
      } else {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      _desktopPage = await locator<Api>().getDesktopPage(currentModule);
    }

    desktopPage = _desktopPage;
  }

  getData(ConnectivityStatus connectivityStatus) async {
    setState(ViewState.busy);
    await getDeskSidebarItems(connectivityStatus);

    currentModule = modules[0].label;

    await getDesktopPage(
      connectionStatus: connectivityStatus,
      currentModule: currentModule,
    );
    setState(ViewState.idle);
  }
}
