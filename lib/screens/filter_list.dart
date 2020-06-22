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

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  List filters = [];
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            _fbKey.currentState.save();
            var formValue = _fbKey.currentState.value;
            formValue.forEach((k, v) {
              if (v != null) {
                if (k == '_assign' && v != '') {
                  filters.add([widget.wireframe["name"], k, "like", "%$v%"]);
                } else {
                  if (v != "") {
                    filters.add([widget.wireframe["name"], k, "=", v]);
                  }
                }
              }
            });

            localStorage.setString(
              '${widget.wireframe["name"]}Filter',
              json.encode(filters),
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
          child: Icon(
            Icons.done,
            color: Colors.blueGrey,
          ),
        ),
        body: FormBuilder(
          key: _fbKey,
          child: ListView(
              padding: EdgeInsets.all(10),
              children: widget.wireframe["fields"].where((field) {
                return field["in_standard_filter"] == 1;
              }).map<Widget>((field) {
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
                      title: generateChildWidget(field, val),
                    ),
                    Divider(
                      height: 10.0,
                    ),
                  ],
                );
              }).toList()),
        ));
  }
}
