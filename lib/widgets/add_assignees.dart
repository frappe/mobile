import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/utils/http.dart';
import 'package:frappe_app/widgets/link_field.dart';

class AddAssignees extends StatefulWidget {
  final List assignments;
  final String doctype;
  final String name;

  AddAssignees({
    @required this.assignments,
    @required this.doctype,
    @required this.name,
  });

  @override
  _AddAssigneesState createState() => _AddAssigneesState();
}

class _AddAssigneesState extends State<AddAssignees> {
  var newAssignees = [];

  void _addAssignees() async {
    var data = {
      'assign_to': json.encode(newAssignees),
      'assign_to_me': 0,
      'description': 'This is better subject',
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
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return IssueDetailResponse.fromJson(response2.data);
      return;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  _removeAssignee(doctype, name, assignTo) async {
    var data = {'doctype': doctype, 'name': name, 'assign_to': assignTo};

    var response2 = await dio.post(
      '/method/frappe.desk.form.assign_to.remove',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response2.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return IssueDetailResponse.fromJson(response2.data);
      return;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                if (newAssignees.length > 0) {
                  await _addAssignees();
                }
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        body: Builder(
          builder: (builderContext) {
            return Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: LinkField(
                      doctype: 'User',
                      refDoctype: 'Issue',
                      hint: 'Assign To',
                      showInputBorder: true,
                      onSuggestionSelected: (item) {
                        if (item != "") {
                          newAssignees.add(item);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Color.fromRGBO(237, 242, 247, 1),
                    child: Center(
                        child: Text(
                      'Assigned To',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    width: double.infinity,
                    height: 40,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: 220, minHeight: 56.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: widget.assignments.length > 0
                          ? widget.assignments.asMap().entries.map<Widget>(
                              (entry) {
                                var d = entry.value;
                                var i = entry.key;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(5),
                                      right: Radius.circular(5),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        child:
                                            Text(d["owner"][0].toUpperCase()),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        d["owner"],
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () async {
                                          // TODO use response of remaining assignees
                                          await _removeAssignee(
                                            widget.doctype,
                                            widget.name,
                                            d["owner"],
                                          );
                                          showSnackBar('User Removed', builderContext);
                                          setState(() {
                                            widget.assignments.removeAt(i);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              },
                            ).toList()
                          : [
                              Container(
                                child: Text(
                                  'No User Assigned',
                                  style: TextStyle(
                                      fontSize: 18, color: Palette.darkGrey),
                                ),
                              )
                            ],
                    ),
                  ),
                  Container(
                    color: Color.fromRGBO(237, 242, 247, 1),
                    child: Center(
                        child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    width: double.infinity,
                    height: 40,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  ConstrainedBox(
                      constraints:
                          BoxConstraints(maxHeight: 220, minHeight: 56.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: newAssignees.length > 0
                            ? newAssignees.asMap().entries.map<Widget>((entry) {
                                var idx = entry.key;
                                var val = entry.value;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(5),
                                      right: Radius.circular(5),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: Text(val[0].toUpperCase()),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(val),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          newAssignees.removeAt(idx);
                                          setState(() {});
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }).toList()
                            : [
                                Container(
                                  child: Text(
                                    'No User Selected',
                                    style: TextStyle(
                                        fontSize: 18, color: Palette.darkGrey),
                                  ),
                                ),
                              ],
                      ))
                ],
              ),
            );
          },
        ));
  }
}
