import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../views/base_viewmodel.dart';

import '../../model/desk_sidebar_items_response.dart';
import '../../model/desktop_page_response.dart';
import '../../model/offline_storage.dart';

import '../../utils/enums.dart';
import '../../utils/helpers.dart';

@lazySingleton
class HomeViewModel extends BaseViewModel {
  String currentModule;
  List<DeskMessage> modules = [];
  DesktopPageResponse desktopPage;
  Response error;

  refresh(ConnectivityStatus connectivityStatus) async {
    getData();
  }

  switchModule(
    String newModule,
  ) async {
    currentModule = newModule;
    await getDesktopPage(
      currentModule,
    );
    notifyListeners();
  }

  Future getDeskSidebarItems() async {
    DeskSidebarItemsResponse deskSidebarItems;

    var isOnline = await verifyOnline();

    if (!isOnline) {
      var deskSidebarItemsCache =
          await OfflineStorage.getItem('deskSidebarItems');
      deskSidebarItemsCache = deskSidebarItemsCache["data"];

      if (deskSidebarItemsCache != null) {
        deskSidebarItems =
            DeskSidebarItemsResponse.fromJson(deskSidebarItemsCache);
      } else {
        error = Response(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      deskSidebarItems = await locator<Api>().getDeskSideBarItems();
    }

    modules = deskSidebarItems.message;
  }

  getDesktopPage(
    String currentModule,
  ) async {
    DesktopPageResponse _desktopPage;

    var isOnline = await verifyOnline();

    if (!isOnline) {
      var moduleDoctypes = OfflineStorage.getItem('${currentModule}Doctypes');
      moduleDoctypes = moduleDoctypes["data"];

      if (moduleDoctypes != null) {
        _desktopPage = DesktopPageResponse.fromJson(moduleDoctypes);
      } else {
        error = Response(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      _desktopPage = await locator<Api>().getDesktopPage(currentModule);
    }

    desktopPage = _desktopPage;
  }

  getData() async {
    setState(ViewState.busy);
    await getDeskSidebarItems();

    currentModule = modules[0].label;

    await getDesktopPage(
      currentModule,
    );
    setState(ViewState.idle);
  }
}
