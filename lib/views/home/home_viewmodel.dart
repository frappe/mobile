import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/datamodels/desk_sidebar_items_response.dart';
import 'package:frappe_app/datamodels/desktop_page_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/cache_helper.dart';
import 'package:frappe_app/utils/config_helper.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HomeViewModel extends BaseViewModel {
  String currentModule = ConfigHelper().activeModules.keys.first;
  List<DeskMessage> activeModules = [];
  DesktopPageResponse desktopPage;

  refresh(ConnectivityStatus connectivityStatus) async {
    await getActiveModules(connectivityStatus);
    notifyListeners();
  }

  switchModule(String newModule) {
    currentModule = newModule;
    notifyListeners();
  }

  Future getActiveModules(ConnectivityStatus connectionStatus) async {
    DeskSidebarItemsResponse deskSidebarItems;
    var _activeModules;
    if (ConfigHelper().activeModules != null) {
      _activeModules = ConfigHelper().activeModules;
    } else {
      _activeModules = {};
    }

    var isOnline = await verifyOnline();

    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var deskSidebarItemsCache =
          await CacheHelper.getCache('deskSidebarItems');
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

    var modules = deskSidebarItems.message.where((m) {
      return _activeModules.keys.contains(m.name) &&
          _activeModules[m.name].length > 0;
    }).toList();

    activeModules = modules;
    notifyListeners();
  }

  DesktopPageResponse filterActiveDoctypes({
    @required DesktopPageResponse desktopPage,
    @required String module,
  }) {
    var activeModules = ConfigHelper().activeModules;
    desktopPage.message.shortcuts.items =
        desktopPage.message.shortcuts.items.where((item) {
      return item.type == "DocType" &&
          activeModules[module].contains(item.label);
    }).toList();

    desktopPage.message.cards.items.forEach((item) {
      item.links = item.links.where((item) {
        return activeModules[module].contains(item.label);
      }).toList();
    });

    desktopPage.message.cards.items =
        desktopPage.message.cards.items.where((item) {
      return item.links.isNotEmpty;
    }).toList();

    return desktopPage;
  }

  getData({
    @required ConnectivityStatus connectionStatus,
    @required String currentModule,
  }) async {
    setState(ViewState.busy);
    DesktopPageResponse _desktopPage;

    var isOnline = await verifyOnline();

    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var moduleDoctypes =
          await CacheHelper.getCache('${currentModule}Doctypes');
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
    setState(ViewState.idle);
  }
}
