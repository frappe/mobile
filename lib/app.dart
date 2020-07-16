import 'dart:convert';

import 'package:flutter/material.dart';
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

// const doctypeFieldnames = {
//   'Issue': [
//     "`tabIssue`.`name`",
//     "`tabIssue`.`status`",
//     "`tabIssue`.`subject`",
//     "`tabIssue`.`modified`",
//     "`tabIssue`.`_assign`",
//     "`tabIssue`.`_seen`",
//     "`tabIssue`.`_liked_by`",
//     "`tabIssue`.`_comments`"
//   ],
//   'Opportunity': [
//     "`tabOpportunity`.`name`",
//     "`tabOpportunity`.`status`",
//     "`tabOpportunity`.`title`",
//     "`tabOpportunity`.`modified`",
//     "`tabOpportunity`.`_assign`",
//     "`tabOpportunity`.`_seen`",
//     "`tabOpportunity`.`_liked_by`",
//     "`tabOpportunity`.`_comments`"
//   ]
// };

class Router extends StatelessWidget {
  final ViewType viewType;
  final String doctype;
  final String name;
  final List filters;

  Router({
    @required this.viewType,
    @required this.doctype,
    this.name,
    this.filters,
  });

  Future _fetchMeta(String doctype, context) async {
    return processData(doctype, viewType, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _fetchMeta(doctype, context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docMeta = snapshot.data["docs"][0];
              docMeta["field_label"] = {
                "_assign": "Assigned To",
                "_liked_by": "Liked By"
              };
              docMeta["fields"].forEach((field) {
                docMeta["field_label"][field["fieldname"]] = field["label"];
              });
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
                return FilterList(
                  filters: filters,
                  wireframe: docMeta,
                  appBarTitle: "Filter $doctype",
                );
              } else if (viewType == ViewType.newForm) {
                return NewForm(docMeta);
              }
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
