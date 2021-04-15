// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../model/doctype_response.dart';
import '../views/desk/desk_view.dart';
import '../views/email_form.dart';
import '../views/form_view/form_view.dart';
import '../views/home_view.dart';
import '../views/list_view/list_view.dart';
import '../views/login/login_view.dart';
import '../views/new_doc/new_doc_view.dart';
import '../views/no_internet.dart';
import '../views/queue.dart';
import '../views/queue_error.dart';
import '../views/session_expired.dart';
import '../widgets/email_box.dart';

class Routes {
  static const String frappeApp = '/';
  static const String login = '/Login';
  static const String deskView = '/desk-view';
  static const String customListView = '/custom-list-view';
  static const String newDoc = '/new-doc';
  static const String formView = '/form-view';
  static const String sessionExpired = '/session-expired';
  static const String noInternet = '/no-internet';
  static const String emailForm = '/email-form';
  static const String queueError = '/queue-error';
  static const String queueList = '/queue-list';
  static const String viewEmail = '/view-email';
  static const String homeView = '/home-view';
  static const all = <String>{
    frappeApp,
    login,
    deskView,
    customListView,
    newDoc,
    formView,
    sessionExpired,
    noInternet,
    emailForm,
    queueError,
    queueList,
    viewEmail,
    homeView,
  };
}

class MyRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.frappeApp, page: FrappeApp),
    RouteDef(Routes.login, page: Login),
    RouteDef(Routes.deskView, page: DeskView),
    RouteDef(Routes.customListView, page: CustomListView),
    RouteDef(Routes.newDoc, page: NewDoc),
    RouteDef(Routes.formView, page: FormView),
    RouteDef(Routes.sessionExpired, page: SessionExpired),
    RouteDef(Routes.noInternet, page: NoInternet),
    RouteDef(Routes.emailForm, page: EmailForm),
    RouteDef(Routes.queueError, page: QueueError),
    RouteDef(Routes.queueList, page: QueueList),
    RouteDef(Routes.viewEmail, page: ViewEmail),
    RouteDef(Routes.homeView, page: HomeView),
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
    DeskView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => DeskView(),
        settings: data,
      );
    },
    CustomListView: (data) {
      final args = data.getArgs<CustomListViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CustomListView(meta: args.meta),
        settings: data,
      );
    },
    NewDoc: (data) {
      final args = data.getArgs<NewDocArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => NewDoc(meta: args.meta),
        settings: data,
      );
    },
    FormView: (data) {
      final args = data.getArgs<FormViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => FormView(
          meta: args.meta,
          name: args.name,
          queued: args.queued,
          queuedData: args.queuedData,
        ),
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
    HomeView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomeView(),
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
  final DoctypeResponse meta;
  CustomListViewArguments({@required this.meta});
}

/// NewDoc arguments holder class
class NewDocArguments {
  final DoctypeResponse meta;
  NewDocArguments({@required this.meta});
}

/// FormView arguments holder class
class FormViewArguments {
  final DoctypeResponse meta;
  final String name;
  final bool queued;
  final Map<dynamic, dynamic> queuedData;
  FormViewArguments(
      {@required this.meta, this.name, this.queued = false, this.queuedData});
}

/// NoInternet arguments holder class
class NoInternetArguments {
  final bool hideAppBar;
  NoInternetArguments({@required this.hideAppBar = false});
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

/// QueueError arguments holder class
class QueueErrorArguments {
  final Key key;
  final String error;
  final Map<dynamic, dynamic> dataToUpdate;
  QueueErrorArguments(
      {this.key, @required this.error, @required this.dataToUpdate});
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
