import 'package:flutter/material.dart';
import 'package:frappe_app/views/home_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/router.gr.dart';

import 'lifecycle_manager.dart';
import 'app/locator.dart';

import 'model/config.dart';
import 'utils/enums.dart';

import 'services/connectivity_service.dart';
import 'services/navigation_service.dart';

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
      _isLoggedIn = Config().isLoggedIn;
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
                      ? HomeView()
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
