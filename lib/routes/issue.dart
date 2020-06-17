import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/app.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/http.dart';
import 'package:frappe_app/utils/response_models.dart';

import '../constants.dart';
import '../utils/helpers.dart';
import '../widgets/form_view.dart';
import '../widgets/filter_list.dart';
import '../widgets/list_view.dart';

Map wireframe = {
  "doctype": "Issue",
  "subject_field": "subject",
  "fieldnames": [
    "`tabIssue`.`name`",
    "`tabIssue`.`status`",
    "`tabIssue`.`subject`",
    "`tabIssue`.`raised_by`",
    "`tabIssue`.`_comments`",
    "`tabIssue`.`modified`",
    "`tabIssue`.`_assign`",
    "`tabIssue`.`_seen`",
    "`tabIssue`.`priority`",
    "`tabIssue`.`support_level`",
    "`tabIssue`.`_liked_by`"
  ],
  "fields": [
    {
      "fieldtype": "Link",
      "refDoctype": 'Issue',
      "hint": 'Issue Type',
      "doctype": 'Issue Type',
      "fieldname": 'issue_type',
      "in_standard_filter": true,
      "hidden": false
    },
    {
      "fieldname": "customer",
      "fieldtype": "Link",
      "refDoctype": 'Issue',
      "hint": 'Customer',
      "doctype": 'Customer',
      "hidden": false
    },
    {
      "fieldtype": "Link",
      "refDoctype": 'Issue',
      "hint": 'Issue Priority',
      "doctype": 'Issue Priority',
      "fieldname": 'priority',
      "in_standard_filter": true,
      "hidden": false
    },
    {
      "fieldtype": "Select",
      "hint": 'Issues Found In',
      "fieldname": 'module',
      "is_custom_field": 1,
      "hidden": false
    },
    {
      "fieldtype": "Select",
      "fieldname": 'agreement_fulfilled',
      "hint": "SLA",
      "hidden": false
    },
    {
      "fieldname": 'name',
      "in_list_view": true,
    },
    {
      "fieldtype": "Select",
      "fieldname": 'status',
      "hint": "Issue Status",
      "in_standard_filter": true,
      "in_list_view": true,
      "hidden": false
    },
    {
      "fieldtype": "Link",
      "fieldname": '_assign',
      "hint": "Assigned To",
      "doctype": 'User',
      "match_operator": "like",
      "refDoctype": 'Issue',
      "in_standard_filter": true,
    },
    {
      "fieldname": 'subject',
      "in_list_view": true,
    },
    {
      "fieldname": 'raised_by',
      "in_list_view": true,
    },
    {
      "fieldname": '_comments',
      "in_list_view": true,
    },
  ]
};

class ModuleView extends StatelessWidget {
  static const _supportedModules = ['Support', 'CRM'];
  final user = localStorage.getString('user');

  Future _fetchSideBarItems(context) async {
    // method/frappe.desk.desktop.get_desk_sidebar_items
    final response2 = await dio.post(
      '/method/frappe.desk.desktop.get_desk_sidebar_items',
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response2.statusCode == 200) {
      return DioGetSideBarItemsResponse.fromJson(response2.data).values;
    } else if (response2.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  void _choiceAction(String choice, context) {
    if (choice == Constants.Logout) {
      logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchSideBarItems(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var modules = snapshot.data["Modules"];
          var modulesWidget = modules.where((m) {
            return _supportedModules.contains(m["name"]);
          }).map<Widget>((m) {
            return ListTile(
              title: Text(m["label"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DoctypeView(m["name"]);
                    },
                  ),
                );
              },
            );
          }).toList();
          return Scaffold(
            appBar: AppBar(
              leading: PopupMenuButton<String>(
                onSelected: (choice) => _choiceAction(choice, context),
                icon: CircleAvatar(
                  child: Text(
                    user[0].toUpperCase(),
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Palette.bgColor,
                ),
                itemBuilder: (BuildContext context) {
                  return Constants.choices.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
            body: ListView(
              children: modulesWidget,
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class DoctypeView extends StatelessWidget {
  static const _supportedDoctypes = ['Issue', 'Opportunity'];

  final String module;

  DoctypeView(this.module);

  Future _fetchDoctypes(module) async {
    final response2 = await dio.post(
      '/method/frappe.desk.desktop.get_desktop_page',
      data: {
        'page': module,
      },
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response2.statusCode == 200) {
      return DioDesktopPageResponse.fromJson(response2.data).values;
    } else if (response2.statusCode == 403) {
      // logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDoctypes(module),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var doctypes = snapshot.data["cards"]["items"][0]["links"];
          var modulesWidget = doctypes.where((m) {
            return _supportedDoctypes.contains(m["name"]);
          }).map<Widget>((m) {
            return ListTile(
              title: Text(m["label"]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Router(doctype: m["name"], viewType: ViewType.list,);
                    },
                  ),
                );
                // m["name"];
              },
            );
          }).toList();
          return Scaffold(
            appBar: AppBar(),
            body: ListView(
              children: modulesWidget,
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class IssueDetail extends StatefulWidget {
  final String name;
  final String title;

  const IssueDetail(this.name, this.title);

  @override
  _IssueDetailState createState() => _IssueDetailState();
}

class _IssueDetailState extends State<IssueDetail> {
  Future futureProcessedData;

  @override
  void initState() {
    super.initState();
    futureProcessedData = processData(
      wireframe,
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureProcessedData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FormView(
              doctype: wireframe["doctype"],
              name: widget.name,
              wireframe: wireframe,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        });
  }
}

class FilterIssue extends StatefulWidget {
  final List filters;

  FilterIssue([this.filters]);
  @override
  _FilterIssueState createState() => _FilterIssueState();
}

class _FilterIssueState extends State<FilterIssue> {
  Future futureProcessedData;

  @override
  void initState() {
    super.initState();
    futureProcessedData =
        processData(wireframe, true, viewType: ViewType.filter);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureProcessedData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FilterList(
              filters: widget.filters,
              appBarTitle: 'Filter ${wireframe["doctype"]}',
              filterCallback: (f) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return IssueList(filters: f);
                }));
              },
              wireframe: wireframe,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        });
  }
}

class IssueList extends StatefulWidget {
  final filters;

  IssueList({this.filters});
  @override
  _IssueListState createState() => _IssueListState();
}

class _IssueListState extends State<IssueList> {
  Future futureProcessedData;

  @override
  void initState() {
    super.initState();
    futureProcessedData = processData(wireframe, false);
  }

  Future fetchData() async {
    futureProcessedData = processData(wireframe, false);
  }

  @override
  Widget build(BuildContext context) {
    List defaultFilters = [];

    if (widget.filters == null) {
      // cached filters
      if (localStorage.containsKey('${wireframe["doctype"]}Filter')) {
        defaultFilters = json
            .decode(localStorage.getString('${wireframe["doctype"]}Filter'));
      } else if (localStorage.containsKey('user')) {
        defaultFilters.add([
          wireframe["doctype"],
          "_assign",
          "like",
          "%${localStorage.getString('user')}%"
        ]);
      }
    }
    return Container();
    // return Scaffold(
    //   body: FutureBuilder(
    //       future: futureProcessedData,
    //       builder: (context, snapshot) {
    //         if (snapshot.hasData) {
    //           return CustomListView(
    //             appBarTitle: wireframe["doctype"],
    //             doctype: wireframe["doctype"],
    //             fieldnames: wireframe["fieldNames"],
    //             filters: widget.filters ?? defaultFilters,
    //             wireframe: wireframe,
    //             filterCallback: (filters) {
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) {
    //                     return FilterIssue(filters);
    //                   },
    //                 ),
    //               );
    //             },
    //             detailCallback: (name, title) {
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) {
    //                     return IssueDetail(name, title);
    //                   },
    //                 ),
    //               );
    //             },
    //           );
    //         } else if (snapshot.hasError) {
    //           return Text("${snapshot.error}");
    //         }
    //         // By default, show a loading spinner.
    //         return Center(child: CircularProgressIndicator());
    //       }),
    // );
  }
}
