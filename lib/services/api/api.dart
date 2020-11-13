import 'package:flutter/foundation.dart';

import '../../datamodels/doctype_response.dart';
import '../../datamodels/desktop_page_response.dart';
import '../../datamodels/desk_sidebar_items_response.dart';
import '../../datamodels/login_response.dart';

abstract class Api {
  Future<LoginResponse> login(String usr, String pwd);
  Future<DeskSidebarItemsResponse> getDeskSideBarItems();
  Future<DesktopPageResponse> getDesktopPage(String module);
  Future<DoctypeResponse> getDoctype(String doctype);
  Future<List> fetchList({
    @required List fieldnames,
    @required String doctype,
    @required DoctypeDoc meta,
    List filters,
    pageLength,
    offset,
  });
}
