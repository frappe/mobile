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
import 'views/simple_form.dart';
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
    var cachedMeta = await CacheHelper.getCache('${doctype}Meta');
    var filter = await CacheHelper.getCache('${doctype}Filter');
    DoctypeResponse metaResponse;

    var isOnline = await verifyOnline();

    filter = filter["data"];

    if (isOnline) {
      if (cachedMeta["data"] != null) {
        DateTime cacheTime = cachedMeta["timestamp"];
        var cacheTimeElapsedMins =
            DateTime.now().difference(cacheTime).inMinutes;
        if (cacheTimeElapsedMins > 15) {
          metaResponse = await locator<Api>().getDoctype(doctype);
        } else {
          metaResponse = DoctypeResponse.fromJson(
              Map<String, dynamic>.from(cachedMeta["data"]));
        }
      } else {
        metaResponse = await locator<Api>().getDoctype(doctype);
      }
    } else {
      if (cachedMeta["data"] != null) {
        metaResponse = DoctypeResponse.fromJson(
            Map<String, dynamic>.from(cachedMeta["data"]));
      } else {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
    }

    return {
      "meta": metaResponse,
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
            var docMeta = (snapshot.data["meta"] as DoctypeResponse).docs[0];

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
                DoctypeField(
                  isDefaultFilter: 1,
                  fieldname: "_assign",
                  options: "User",
                  label: "Assigned To",
                  fieldtype: "Link",
                )
              ];
              docMeta.fields.addAll(defaultFilters);
              return FilterList(
                filters: filters,
                meta: docMeta,
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
