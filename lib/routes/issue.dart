import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/utils/enums.dart';

import '../utils/helpers.dart';
import '../widgets/form_view.dart';
import '../widgets/filter_list.dart';
import '../widgets/list_view.dart';

Map wireframe = {
  "doctype": "Issue",
  "subject_field": "subject",
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
    futureProcessedData = processData(wireframe, true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureProcessedData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FormView(
              appBarTitle: widget.title,
              doctype: 'Issue',
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
    futureProcessedData = processData(wireframe, true, ViewType.filter);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureProcessedData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FilterList(
              filters: widget.filters,
              appBarTitle: 'Filter Issue',
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
    const fieldNames = const [
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
    ];

    if (widget.filters == null) {
      // cached filters
      if (localStorage.containsKey('IssueFilter')) {
        defaultFilters = json.decode(localStorage.getString('IssueFilter'));
      } else if (localStorage.containsKey('user')) {
        defaultFilters.add([
          wireframe["doctype"],
          "_assign",
          "like",
          "%${localStorage.getString('user')}%"
        ]);
      }
    }
    return Scaffold(
      body: FutureBuilder(
          future: futureProcessedData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomListView(
                appBarTitle: wireframe["doctype"],
                doctype: wireframe["doctype"],
                fieldnames: fieldNames,
                filters: widget.filters ?? defaultFilters,
                wireframe: wireframe,
                filterCallback: (filters) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return FilterIssue(filters);
                      },
                    ),
                  );
                },
                detailCallback: (name, title) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return IssueDetail(name, title);
                      },
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
