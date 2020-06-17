import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/widgets/filter_list.dart';
import 'package:frappe_app/widgets/form_view.dart';
import 'package:frappe_app/widgets/list_view.dart';
import 'package:frappe_app/widgets/new_form.dart';
import 'package:google_fonts/google_fonts.dart';

import './pages/login.dart';
import './routes/issue.dart';
import './main.dart';

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
      title: 'Support App',
      theme: new ThemeData(
        // primaryColor: Color.fromRGBO(68, 65, 65, 1),
        textTheme: GoogleFonts.interTextTheme(),
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
                : Center(child: CircularProgressIndicator())),
        // body: Login()),
      ),
      routes: <String, WidgetBuilder>{
        // Set routes for using the Navigator.
        '/issue': (BuildContext context) => IssueList(),
        '/login': (BuildContext context) => Login(),
        '/modules': (BuildContext context) => ModuleView(),
      },
    );
  }
}

const doctypeFieldnames = {
  'Issue': [
    "`tabIssue`.`name`",
    "`tabIssue`.`status`",
    "`tabIssue`.`subject`",
    "`tabIssue`.`modified`",
    "`tabIssue`.`_assign`",
    "`tabIssue`.`_seen`",
    "`tabIssue`.`_liked_by`",
    "`tabIssue`.`_comments`"
  ],
  'Opportunity': [
    "`tabOpportunity`.`name`",
    "`tabOpportunity`.`status`",
    "`tabOpportunity`.`title`",
    "`tabOpportunity`.`modified`",
    "`tabOpportunity`.`_assign`",
    "`tabOpportunity`.`_seen`",
    "`tabOpportunity`.`_liked_by`",
    "`tabOpportunity`.`_comments`"
  ]
};

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
    return processData2(doctype, viewType, context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchMeta(doctype, context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docMeta = snapshot.data.docs[0];
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
                  defaultFilters = json.decode(
                      localStorage.getString('${doctype}Filter'));
                } else if (localStorage.containsKey('user')) {
                  defaultFilters.add([
                    doctype,
                    "_assign",
                    "like",
                    "%${localStorage.getString('user')}%"
                  ]);
                }
              }

              return CustomListView(
                filters: filters ?? defaultFilters,
                meta: docMeta,
                doctype: doctype,
                appBarTitle: doctype,
                fieldnames: doctypeFieldnames[doctype]
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
        });
  }
}
