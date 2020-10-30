import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/utils/backend_service.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'lifecycle_manager.dart';
import 'utils/cache_helper.dart';
import 'utils/config_helper.dart';
import 'utils/enums.dart';
import 'utils/helpers.dart';

import 'service_locator.dart';
import 'services/connectivity_service.dart';
import 'services/navigation_service.dart';

import 'screens/no_internet.dart';
import 'screens/session_expired.dart';
import 'screens/custom_persistent_bottom_nav_bar.dart';
import 'screens/filter_list.dart';
import 'screens/form_view.dart';
import 'screens/list_view.dart';
import 'screens/simple_form.dart';
import 'screens/login.dart';
import 'screens/module_view.dart';

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
          onGenerateRoute: (routeSettings) {
            switch (routeSettings.name) {
              case 'login':
                return MaterialPageRoute(builder: (context) => Login());
              case 'session_expired':
                return MaterialPageRoute(
                    builder: (context) => SessionExpired());
              case 'no_internet':
                return MaterialPageRoute(builder: (context) => NoInternet());
              default:
                return MaterialPageRoute(builder: (context) => FrappeApp());
            }
          },
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
                      ? CustomPersistentBottomNavBar()
                      : Login()
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
          routes: <String, WidgetBuilder>{
            // Set routes for using the Navigator.
            '/login': (BuildContext context) => Login(),
            '/modules': (BuildContext context) => ModuleView(),
          },
        ),
      ),
    );
  }
}

class CustomRouter extends StatelessWidget {
  final ViewType viewType;
  final String doctype;
  final String name;
  final List filters;
  final Function filterCallback;
  final Map queuedData;
  final bool queued;

  CustomRouter({
    @required this.viewType,
    @required this.doctype,
    this.name,
    this.filters,
    this.filterCallback,
    this.queued,
    this.queuedData,
  });

  _getData() async {
    var meta = await CacheHelper.getCache('${doctype}Meta');
    var filter = await CacheHelper.getCache('${doctype}Filter');
    meta = meta["data"];
    filter = filter["data"];
    if (meta == null) {
      var isOnline = await verifyOnline();
      if (isOnline) {
        meta = await BackendService.getDoctype(doctype);
      } else {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
    }
    return {
      "meta": meta,
      "filter": filter,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            var docMeta = snapshot.data["meta"];
            docMeta = docMeta["docs"][0];

            if (viewType == ViewType.list) {
              var defaultFilters = [];
              if (filters == null) {
                // cached filters
                // TODO
                if (snapshot.data["filter"] != null) {
                  defaultFilters = snapshot.data["filter"];
                } else if (ConfigHelper().userId != null) {
                  defaultFilters.add(
                    [doctype, "_assign", "like", "%${ConfigHelper().userId}%"],
                  );
                }
              }

              return CustomListView(
                filters: filters ?? defaultFilters,
                meta: docMeta,
                doctype: doctype,
                appBarTitle: doctype,
                fieldnames: generateFieldnames(doctype, docMeta),
              );
            } else if (viewType == ViewType.form) {
              return FormView(
                doctype: doctype,
                name: name,
                meta: docMeta,
                queued: queued ?? false,
                queuedData: queuedData,
              );
            } else if (viewType == ViewType.filter) {
              var defaultFilters = [
                {
                  "is_default_filter": 1,
                  "fieldname": "_assign",
                  "options": "User",
                  "label": "Assigned To",
                  "fieldtype": "Link"
                },
              ];
              docMeta["fields"].addAll(defaultFilters);
              return FilterList(
                filters: filters,
                wireframe: docMeta,
                filterCallback: filterCallback,
                appBarTitle: "Filter $doctype",
              );
            } else if (viewType == ViewType.newForm) {
              return SimpleForm(docMeta);
            }
          } else if (snapshot.hasError) {
            return handleError(snapshot.error);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
