import 'package:auto_route/auto_route_annotations.dart';
import 'package:frappe_app/views/add_assignees.dart';
import 'package:frappe_app/views/add_review.dart';
import 'package:frappe_app/views/add_tags.dart';
import 'package:frappe_app/views/file_picker.dart';
import 'package:frappe_app/views/queue.dart';
import 'package:frappe_app/views/share.dart';
import 'package:frappe_app/widgets/email_box.dart';

import '../views/activate_modules/activate_modules_view.dart';
import '../views/comment_input.dart';
import '../views/doctype_view.dart';
import '../views/email_form.dart';
import '../views/home.dart';
import '../views/queue_error.dart';
import '../views/view_docinfo.dart';
import '../views/no_internet.dart';
import '../views/session_expired.dart';
import '../views/login/login_view.dart';
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
