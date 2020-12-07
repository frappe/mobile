// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../screens/activate_modules.dart';
import '../screens/doctype_view.dart';
import '../screens/home.dart';
import '../screens/login.dart';
import '../screens/no_internet.dart';
import '../screens/session_expired.dart';
import '../utils/enums.dart';

class Routes {
  static const String frappeApp = '/';
  static const String login = '/Login';
  static const String home = '/Home';
  static const String activateModules = '/activate-modules';
  static const String doctypeView = '/doctype-view';
  static const String sessionExpired = '/session-expired';
  static const String noInternet = '/no-internet';
  static const String customRouter = '/custom-router';
  static const all = <String>{
    frappeApp,
    login,
    home,
    activateModules,
    doctypeView,
    sessionExpired,
    noInternet,
    customRouter,
  };
}

class MyRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.frappeApp, page: FrappeApp),
    RouteDef(Routes.login, page: Login),
    RouteDef(Routes.home, page: Home),
    RouteDef(Routes.activateModules, page: ActivateModules),
    RouteDef(Routes.doctypeView, page: DoctypeView),
    RouteDef(Routes.sessionExpired, page: SessionExpired),
    RouteDef(Routes.noInternet, page: NoInternet),
    RouteDef(Routes.customRouter, page: CustomRouter),
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
    ActivateModules: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ActivateModules(),
        settings: data,
      );
    },
    DoctypeView: (data) {
      final args = data.getArgs<DoctypeViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => DoctypeView(args.module),
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
    CustomRouter: (data) {
      final args = data.getArgs<CustomRouterArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CustomRouter(
          viewType: args.viewType,
          doctype: args.doctype,
          name: args.name,
          filters: args.filters,
          filterCallback: args.filterCallback,
          queued: args.queued,
          queuedData: args.queuedData,
        ),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// DoctypeView arguments holder class
class DoctypeViewArguments {
  final String module;
  DoctypeViewArguments({@required this.module});
}

/// NoInternet arguments holder class
class NoInternetArguments {
  final bool hideAppBar;
  NoInternetArguments({@required this.hideAppBar = false});
}

/// CustomRouter arguments holder class
class CustomRouterArguments {
  final ViewType viewType;
  final String doctype;
  final String name;
  final List<dynamic> filters;
  final Function filterCallback;
  final bool queued;
  final Map<dynamic, dynamic> queuedData;
  CustomRouterArguments(
      {@required this.viewType,
      @required this.doctype,
      this.name,
      this.filters,
      this.filterCallback,
      this.queued,
      this.queuedData});
}
