import 'package:auto_route/auto_route_annotations.dart';
import 'package:frappe_app/screens/add_assignees.dart';
import 'package:frappe_app/screens/add_review.dart';
import 'package:frappe_app/screens/add_tags.dart';
import 'package:frappe_app/screens/file_picker.dart';
import 'package:frappe_app/screens/queue.dart';
import 'package:frappe_app/screens/share.dart';
import 'package:frappe_app/widgets/email_box.dart';

import '../screens/activate_modules.dart';
import '../screens/comment_input.dart';
import '../screens/doctype_view.dart';
import '../screens/email_form.dart';
import '../screens/home.dart';
import '../screens/queue_error.dart';
import '../screens/view_docinfo.dart';
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
    MaterialRoute(page: CommentInput),
    MaterialRoute(page: EmailForm),
    MaterialRoute(page: ViewDocInfo),
    MaterialRoute(page: QueueError),
    MaterialRoute(page: QueueList),
    MaterialRoute(page: AddAssignees),
    MaterialRoute(page: CustomFilePicker),
    MaterialRoute(page: ViewEmail),
    MaterialRoute(page: AddReview),
    MaterialRoute(page: Share),
    MaterialRoute(page: AddTags),
  ],
)
class $MyRouter {}
