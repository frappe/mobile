import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/app.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/utils/enums.dart';

import '../utils/helpers.dart';

class FilterList extends StatefulWidget {
  final Function filterCallback;
  final Map wireframe;
  final String appBarTitle;
  final List filters;

  FilterList({
    this.filterCallback,
    @required this.wireframe,
    @required this.appBarTitle,
    this.filters,
  });

  static int getFieldFilterIndex(List filters, String field) {
    int idx;
    for (int i = 0; i < filters.length; i++) {
      if (filters[i][1] == field) {
        idx = i;
        break;
      }
    }

    return idx;
  }

  static clearFilters(String doctype) {
    localStorage.setString(
      "${doctype}Filter",
      json.encode([]),
    );
  }

  static List generateFilters(String doctype, Map filters) {
    var transformedFilters;
    var cacheKey = '${doctype}Filter';
    if (localStorage.containsKey(cacheKey)) {
      transformedFilters = json.decode(localStorage.getString(cacheKey));
    } else {
      transformedFilters = [];
    }

    filters.forEach((k, v) {
      if (v != null) {
        if (k == '_assign' && v != '') {
          transformedFilters.add([doctype, k, "like", "%$v%"]);
        } else {
          if (v != "") {
            transformedFilters.add([doctype, k, "=", v]);
          }
        }
      }
    });

    localStorage.setString(
      cacheKey,
      json.encode(transformedFilters),
    );

    return transformedFilters;
  }

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          FlatButton(
            child: Text('Clear'),
            onPressed: () {
              FilterList.clearFilters(widget.wireframe["name"]);
              _fbKey.currentState.reset();
              widget.filters.clear();
              setState(() {});
            },
          ),
          FlatButton(
            child: Text('Apply'),
            onPressed: () {
              _fbKey.currentState.save();

              var filters = FilterList.generateFilters(
                widget.wireframe["name"],
                _fbKey.currentState.value,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Router(
                      viewType: ViewType.list,
                      doctype: widget.wireframe["name"],
                      filters: filters,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FormBuilder(
        key: _fbKey,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: widget.wireframe["fields"].where((field) {
            return field["in_standard_filter"] == 1;
          }).map<Widget>(
            (field) {
              var val = field["val"];

              if (val == null) {
                if (widget.filters != null && widget.filters.length > 0) {
                  for (int i = 0; i < widget.filters.length; i++) {
                    if (widget.filters[i][1] == field["fieldname"]) {
                      val = widget.filters[i][3];
                    }
                  }
                }
              }
              return Column(
                children: <Widget>[
                  ListTile(
                    title: makeControl(field, val),
                  ),
                  Divider(
                    height: 10.0,
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
