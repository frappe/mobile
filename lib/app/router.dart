import 'package:auto_route/auto_route_annotations.dart';

import '../widgets/email_box.dart';
import '../app.dart';

import '../views/form_view/form_view.dart';
import '../views/new_doc/new_doc_view.dart';
import '../views/list_view/list_view.dart';
import '../views/home/home_view.dart';
import '../views/add_assignees/add_assignees_view.dart';
import '../views/add_review/add_review_view.dart';
import '../views/add_tags/add_tags_view.dart';
import '../views/file_picker.dart';
import '../views/queue.dart';
import '../views/share/share_view.dart';
import '../views/comment_input.dart';
import '../views/email_form.dart';
import '../views/queue_error.dart';
import '../views/view_docinfo.dart';
import '../views/no_internet.dart';
import '../views/session_expired.dart';
import '../views/login/login_view.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    // initial route is named "/"
    MaterialRoute(page: FrappeApp, initial: true),
    MaterialRoute(page: Login),
    MaterialRoute(page: Home),
    MaterialRoute(page: CustomListView),
    MaterialRoute(page: NewDoc),
    MaterialRoute(page: FormView),
    MaterialRoute(page: SessionExpired),
    MaterialRoute(page: NoInternet),
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
