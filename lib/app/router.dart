import 'package:auto_route/auto_route_annotations.dart';
import 'package:frappe_app/views/home_view.dart';

import '../widgets/email_box.dart';
import '../app.dart';

import '../views/form_view/form_view.dart';
import '../views/new_doc/new_doc_view.dart';
import '../views/list_view/list_view.dart';
import '../views/desk/desk_view.dart';
import '../views/queue.dart';
import '../views/email_form.dart';
import '../views/queue_error.dart';
import '../views/no_internet.dart';
import '../views/session_expired.dart';
import '../views/login/login_view.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    MaterialRoute(page: FrappeApp, initial: true),
    MaterialRoute(page: Login),
    MaterialRoute(page: DeskView),
    MaterialRoute(page: CustomListView),
    MaterialRoute(page: NewDoc),
    MaterialRoute(page: FormView),
    MaterialRoute(page: SessionExpired),
    MaterialRoute(page: NoInternet),
    MaterialRoute(page: EmailForm),
    MaterialRoute(page: QueueError),
    MaterialRoute(page: QueueList),
    MaterialRoute(page: ViewEmail),
    MaterialRoute(page: HomeView),
  ],
)
class $MyRouter {}
