import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frappe_app/utils/http.dart';
import 'package:google_fonts/google_fonts.dart';

import './main.dart';
import './utils/enums.dart';
import './utils/helpers.dart';

import './screens/filter_list.dart';
import './screens/form_view.dart';
import './screens/list_view.dart';
import './screens/new_form.dart';
import './screens/login.dart';
import './screens/module_view.dart';

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
    if (localStorage.containsKey('isLoggedIn')) {
      bool loggedIn = localStorage.getBool('isLoggedIn');
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
    _isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frappe',
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
              ? _isLoggedIn ? ModuleView() : Login()
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
    );
  }
}

class Router extends StatelessWidget {
  final ViewType viewType;
  final String doctype;
  final String name;
  final List filters;
  final Function filterCallback;

  Router({
    @required this.viewType,
    @required this.doctype,
    this.name,
    this.filters,
    this.filterCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          var docMeta = json.decode(localStorage.getString('${doctype}Meta'));
          docMeta = docMeta["docs"][0];

          if (viewType == ViewType.list) {
            var defaultFilters = [];
            if (filters == null) {
              // cached filters
              if (localStorage.containsKey('${doctype}Filter')) {
                defaultFilters =
                    json.decode(localStorage.getString('${doctype}Filter'));
              } else if (localStorage.containsKey('userId')) {
                defaultFilters.add([
                  doctype,
                  "_assign",
                  "like",
                  "%${Uri.decodeFull(localStorage.getString('userId'))}%"
                ]);
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
              wireframe: docMeta,
            );
          } else if (viewType == ViewType.filter) {
            List defaultFilters = [
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
            return NewForm(docMeta);
          }
        },
      ),
    );
  }
}
