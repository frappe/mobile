import '../../datamodels/desktop_page_response.dart';
import '../../datamodels/desk_sidebar_items_response.dart';
import '../../datamodels/login_response.dart';

abstract class Api {
  Future<LoginResponse> login(String usr, String pwd);
  Future<DeskSidebarItemsResponse> getDeskSideBarItems();
  Future<DesktopPageResponse> getDesktopPage(String module);
  // Future<Response> getDoctype(String doctype);
}
