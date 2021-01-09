// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../datamodels/doctype_response.dart';
import '../views/activate_modules/activate_modules_view.dart';
import '../views/add_assignees.dart';
import '../views/add_review.dart';
import '../views/add_tags.dart';
import '../views/comment_input.dart';
import '../views/email_form.dart';
import '../views/file_picker.dart';
import '../views/form_view.dart';
import '../views/home.dart';
import '../views/list_view.dart';
import '../views/login/login_view.dart';
import '../views/new_doc.dart';
import '../views/no_internet.dart';
import '../views/queue.dart';
import '../views/queue_error.dart';
import '../views/session_expired.dart';
import '../views/share.dart';
import '../views/view_docinfo.dart';
import '../widgets/email_box.dart';

class Routes {
  static const String frappeApp = '/';
  static const String login = '/Login';
  static const String home = '/Home';
  static const String customListView = '/custom-list-view';
  static const String newDoc = '/new-doc';
  static const String formView = '/form-view';
  static const String activateModules = '/activate-modules';
  static const String sessionExpired = '/session-expired';
  static const String noInternet = '/no-internet';
  static const String commentInput = '/comment-input';
  static const String emailForm = '/email-form';
  static const String viewDocInfo = '/view-doc-info';
  static const String queueError = '/queue-error';
  static const String queueList = '/queue-list';
  static const String addAssignees = '/add-assignees';
  static const String customFilePicker = '/custom-file-picker';
  static const String viewEmail = '/view-email';
  static const String addReview = '/add-review';
  static const String share = '/Share';
  static const String addTags = '/add-tags';
  static const all = <String>{
    frappeApp,
    login,
    home,
    customListView,
    newDoc,
    formView,
    activateModules,
    sessionExpired,
    noInternet,
    commentInput,
    emailForm,
    viewDocInfo,
    queueError,
    queueList,
    addAssignees,
    customFilePicker,
    viewEmail,
    addReview,
    share,
    addTags,
  };
}

class MyRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.frappeApp, page: FrappeApp),
    RouteDef(Routes.login, page: Login),
    RouteDef(Routes.home, page: Home),
    RouteDef(Routes.customListView, page: CustomListView),
    RouteDef(Routes.newDoc, page: NewDoc),
    RouteDef(Routes.formView, page: FormView),
    RouteDef(Routes.activateModules, page: ActivateModules),
    RouteDef(Routes.sessionExpired, page: SessionExpired),
    RouteDef(Routes.noInternet, page: NoInternet),
    RouteDef(Routes.commentInput, page: CommentInput),
    RouteDef(Routes.emailForm, page: EmailForm),
    RouteDef(Routes.viewDocInfo, page: ViewDocInfo),
    RouteDef(Routes.queueError, page: QueueError),
    RouteDef(Routes.queueList, page: QueueList),
    RouteDef(Routes.addAssignees, page: AddAssignees),
    RouteDef(Routes.customFilePicker, page: CustomFilePicker),
    RouteDef(Routes.viewEmail, page: ViewEmail),
    RouteDef(Routes.addReview, page: AddReview),
    RouteDef(Routes.share, page: Share),
    RouteDef(Routes.addTags, page: AddTags),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    FrappeApp: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => FrappeApp(),
        settings: data,
      );
    },
    Login: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Login(),
        settings: data,
      );
    },
    Home: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Home(),
        settings: data,
      );
    },
    CustomListView: (data) {
      final args = data.getArgs<CustomListViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CustomListView(
          doctype: args.doctype,
          filterCallback: args.filterCallback,
        ),
        settings: data,
      );
    },
    NewDoc: (data) {
      final args = data.getArgs<NewDocArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => NewDoc(doctype: args.doctype),
        settings: data,
      );
    },
    FormView: (data) {
      final args = data.getArgs<FormViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => FormView(
          doctype: args.doctype,
          name: args.name,
          queued: args.queued,
          queuedData: args.queuedData,
        ),
        settings: data,
      );
    },
    ActivateModules: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ActivateModules(),
        settings: data,
      );
    },
    SessionExpired: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SessionExpired(),
        settings: data,
      );
    },
    NoInternet: (data) {
      final args = data.getArgs<NoInternetArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => NoInternet(args.hideAppBar),
        settings: data,
      );
    },
    CommentInput: (data) {
      final args = data.getArgs<CommentInputArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CommentInput(
          doctype: args.doctype,
          name: args.name,
          authorEmail: args.authorEmail,
          callback: args.callback,
        ),
        settings: data,
      );
    },
    EmailForm: (data) {
      final args = data.getArgs<EmailFormArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => EmailForm(
          doctype: args.doctype,
          doc: args.doc,
          subjectField: args.subjectField,
          senderField: args.senderField,
          callback: args.callback,
        ),
        settings: data,
      );
    },
    ViewDocInfo: (data) {
      final args = data.getArgs<ViewDocInfoArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => ViewDocInfo(
          doctype: args.doctype,
          name: args.name,
          docInfo: args.docInfo,
          callback: args.callback,
          meta: args.meta,
          doc: args.doc,
        ),
        settings: data,
      );
    },
    QueueError: (data) {
      final args = data.getArgs<QueueErrorArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => QueueError(
          key: args.key,
          error: args.error,
          dataToUpdate: args.dataToUpdate,
        ),
        settings: data,
      );
    },
    QueueList: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => QueueList(),
        settings: data,
      );
    },
    AddAssignees: (data) {
      final args = data.getArgs<AddAssigneesArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => AddAssignees(
          key: args.key,
          doctype: args.doctype,
          name: args.name,
        ),
        settings: data,
      );
    },
    CustomFilePicker: (data) {
      final args = data.getArgs<CustomFilePickerArguments>(
        orElse: () => CustomFilePickerArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => CustomFilePicker(
          doctype: args.doctype,
          name: args.name,
          callback: args.callback,
        ),
        settings: data,
      );
    },
    ViewEmail: (data) {
      final args = data.getArgs<ViewEmailArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => ViewEmail(
          title: args.title,
          time: args.time,
          senderFullName: args.senderFullName,
          sender: args.sender,
          content: args.content,
        ),
        settings: data,
      );
    },
    AddReview: (data) {
      final args = data.getArgs<AddReviewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => AddReview(
          key: args.key,
          doctype: args.doctype,
          name: args.name,
          meta: args.meta,
          doc: args.doc,
          docInfo: args.docInfo,
        ),
        settings: data,
      );
    },
    Share: (data) {
      final args = data.getArgs<ShareArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => Share(
          key: args.key,
          doctype: args.doctype,
          docInfo: args.docInfo,
          name: args.name,
        ),
        settings: data,
      );
    },
    AddTags: (data) {
      final args = data.getArgs<AddTagsArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => AddTags(
          key: args.key,
          doctype: args.doctype,
          name: args.name,
        ),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// CustomListView arguments holder class
class CustomListViewArguments {
  final String doctype;
  final Function filterCallback;
  CustomListViewArguments({@required this.doctype, this.filterCallback});
}

/// NewDoc arguments holder class
class NewDocArguments {
  final String doctype;
  NewDocArguments({@required this.doctype});
}

/// FormView arguments holder class
class FormViewArguments {
  final String doctype;
  final String name;
  final bool queued;
  final Map<dynamic, dynamic> queuedData;
  FormViewArguments(
      {@required this.doctype,
      this.name,
      this.queued = false,
      this.queuedData});
}

/// NoInternet arguments holder class
class NoInternetArguments {
  final bool hideAppBar;
  NoInternetArguments({@required this.hideAppBar = false});
}

/// CommentInput arguments holder class
class CommentInputArguments {
  final String doctype;
  final String name;
  final String authorEmail;
  final Function callback;
  CommentInputArguments(
      {@required this.doctype,
      @required this.name,
      @required this.authorEmail,
      @required this.callback});
}

/// EmailForm arguments holder class
class EmailFormArguments {
  final String doctype;
  final String doc;
  final String subjectField;
  final String senderField;
  final Function callback;
  EmailFormArguments(
      {@required this.doctype,
      @required this.doc,
      this.subjectField,
      this.senderField,
      @required this.callback});
}

/// ViewDocInfo arguments holder class
class ViewDocInfoArguments {
  final String doctype;
  final String name;
  final Map<dynamic, dynamic> docInfo;
  final Function callback;
  final DoctypeDoc meta;
  final Map<dynamic, dynamic> doc;
  ViewDocInfoArguments(
      {@required this.doctype,
      @required this.name,
      @required this.docInfo,
      this.callback,
      @required this.meta,
      @required this.doc});
}

/// QueueError arguments holder class
class QueueErrorArguments {
  final Key key;
  final String error;
  final Map<dynamic, dynamic> dataToUpdate;
  QueueErrorArguments(
      {this.key, @required this.error, @required this.dataToUpdate});
}

/// AddAssignees arguments holder class
class AddAssigneesArguments {
  final Key key;
  final String doctype;
  final String name;
  AddAssigneesArguments(
      {this.key, @required this.doctype, @required this.name});
}

/// CustomFilePicker arguments holder class
class CustomFilePickerArguments {
  final String doctype;
  final String name;
  final Function callback;
  CustomFilePickerArguments({this.doctype, this.name, this.callback});
}

/// ViewEmail arguments holder class
class ViewEmailArguments {
  final String title;
  final String time;
  final String senderFullName;
  final String sender;
  final String content;
  ViewEmailArguments(
      {@required this.title,
      @required this.time,
      @required this.senderFullName,
      @required this.sender,
      @required this.content});
}

/// AddReview arguments holder class
class AddReviewArguments {
  final Key key;
  final String doctype;
  final String name;
  final DoctypeDoc meta;
  final Map<dynamic, dynamic> doc;
  final Map<dynamic, dynamic> docInfo;
  AddReviewArguments(
      {this.key,
      @required this.doctype,
      @required this.name,
      @required this.meta,
      @required this.doc,
      @required this.docInfo});
}

/// Share arguments holder class
class ShareArguments {
  final Key key;
  final String doctype;
  final Map<dynamic, dynamic> docInfo;
  final String name;
  ShareArguments(
      {this.key,
      @required this.doctype,
      @required this.docInfo,
      @required this.name});
}

/// AddTags arguments holder class
class AddTagsArguments {
  final Key key;
  final String doctype;
  final String name;
  AddTagsArguments({this.key, @required this.doctype, @required this.name});
}
