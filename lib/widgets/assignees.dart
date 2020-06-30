import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../config/palette.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';
import '../widgets/button.dart';
import '../widgets/card_list_tile.dart';
import '../form/controls/link_field.dart';




class Assignees extends StatefulWidget {
  final List assignments;
  final String doctype;
  final String name;
  final Function callback;

  Assignees({
    @required this.assignments,
    @required this.doctype,
    @required this.name,
    @required this.callback,
  });

  @override
  _AssigneesState createState() => _AssigneesState();
}

class _AssigneesState extends State<Assignees> {
  var newAssignees = [];

  void _addAssignees() async {
    var data = {
      'assign_to': json.encode(newAssignees),
      'assign_to_me': 0,
      'doctype': widget.doctype,
      'name': widget.name,
      'bulk_assign': false,
      're_assign': false
    };

    var response2 = await dio.post(
      '/method/frappe.desk.form.assign_to.add',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response2.statusCode == 200) {
      widget.callback();
      return;
    } else {
      throw Exception('Failed to load album');
    }
  }

  _removeAssignee(doctype, name, assignTo) async {
    var data = {
      'doctype': doctype,
      'name': name,
      'assign_to': assignTo,
    };

    var response2 = await dio.post(
      '/method/frappe.desk.form.assign_to.remove',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response2.statusCode == 200) {
      showSnackBar('Assignee Removed', context);
      return;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Widget _buildSelectedAssigneesHeader() {
    return CardListTile(
      title: Text(
        'Selected',
        style: TextStyle(
          fontSize: 18,
          color: Palette.dimTxtColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Button(
        title: 'Assign',
        buttonType: ButtonType.primary,
        onPressed: newAssignees.length > 0
            ? () async {
                await _addAssignees();
                Navigator.of(context).pop();
              }
            : null,
      ),
    );
  }

  List<Widget> _generateChildren() {
    List<Widget> children = [
      SizedBox(
        height: 8,
      ),
      _buildSelectedAssigneesHeader(),
      ..._buildNewAssignees(),
      ..._buildAssignedTo()
    ];

    if (newAssignees.length == 0 && widget.assignments.length == 0) {
      children.add(
        CardListTile(
          title: Text(
            'No Users Assigned',
            style: Palette.altTextStyle,
          ),
        ),
      );
    }

    return children;
  }

  List<Widget> _buildNewAssignees() {
    return newAssignees.asMap().entries.map<Widget>((entry) {
      var idx = entry.key;
      var val = entry.value;
      return CardListTile(
        color: Palette.newIndicatorColor,
        leading: CircleAvatar(
          child: Text(val[0].toUpperCase()),
        ),
        title: Text(val),
        trailing: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            newAssignees.removeAt(idx);
            setState(() {});
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildAssignedTo() {
    return widget.assignments.asMap().entries.map<Widget>(
      (entry) {
        var d = entry.value;
        var i = entry.key;
        return CardListTile(
          leading: CircleAvatar(
            child: Text(d["owner"][0].toUpperCase()),
          ),
          title: Text(
            d["owner"],
          ),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () async {
              // TODO use response of remaining assignees
              await _removeAssignee(
                widget.doctype,
                widget.name,
                d["owner"],
              );

              setState(() {
                widget.assignments.removeAt(i);
              });
            },
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bgColor,
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (builderContext) {
          return Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: FormBuilder(
                    child: LinkField(
                      fillColor: Colors.white,
                      doctype: 'User',
                      refDoctype: 'Issue',
                      hint: 'Assign To',
                      onSuggestionSelected: (item) {
                        if (item != "") {
                          newAssignees.add(item.value);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _generateChildren(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
