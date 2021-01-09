import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:frappe_app/views/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'datamodels/doctype_response.dart';
import 'app/router.gr.dart';

import 'lifecycle_manager.dart';
import 'app/locator.dart';

import 'utils/cache_helper.dart';
import 'utils/config_helper.dart';
import 'utils/enums.dart';
import 'utils/helpers.dart';

import 'services/api/api.dart';
import 'services/connectivity_service.dart';
import 'services/navigation_service.dart';

import 'views/filter_list.dart';
import 'views/form_view.dart';
import 'views/list_view.dart';
import 'views/new_doc.dart';
import 'views/login/login_view.dart';

class FrappeApp extends StatefulWidget {
  @override
  _FrappeAppState createState() => _FrappeAppState();
}

class _FrappeAppState extends State<FrappeApp> {
  bool _isLoggedIn = false;
  bool _isLoaded = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() {
    setState(() {
      _isLoggedIn = ConfigHelper().isLoggedIn;
    });

    _isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return LifeCycleManager(
      child: StreamProvider<ConnectivityStatus>(
        create: (context) =>
            ConnectivityService().connectionStatusController.stream,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Frappe',
          navigatorKey: locator<NavigationService>().navigatorKey,
          onGenerateRoute: MyRouter().onGenerateRoute,
          initialRoute: Routes.frappeApp,
          theme: new ThemeData(
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme.apply(
                  // fontSizeFactor: 0.7,
                  ),
            ),
            disabledColor: Colors.black,
            primaryColor: Colors.white,
            accentColor: Colors.black54,
          ),
          home: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Scaffold(
              body: _isLoaded
                  ? _isLoggedIn
                      ? Home()
                      : Login()
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
