import 'package:auto_route/auto_route_annotations.dart';
import 'package:frappe_app/screens/activate_modules.dart';
import 'package:frappe_app/screens/doctype_view.dart';
import 'package:frappe_app/screens/home.dart';

import '../screens/no_internet.dart';
import '../screens/session_expired.dart';
import '../screens/login.dart';
import '../app.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    MaterialRoute(page: FrappeApp, initial: true),
    MaterialRoute(page: Login),
    MaterialRoute(page: Home),
    MaterialRoute(page: ActivateModules),
    MaterialRoute(page: DoctypeView),
    MaterialRoute(page: SessionExpired),
    MaterialRoute(page: NoInternet),
    MaterialRoute(page: CustomRouter),
  ],
)
class $MyRouter {}
