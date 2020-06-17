import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/utils/http.dart';

import '../app.dart';

class NewForm extends StatefulWidget {
  final Map meta;

  NewForm(this.meta);

  @override
  _NewFormState createState() => _NewFormState();
}

class _NewFormState extends State<NewForm> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

    void _saveForm(doctype, formValue) async {
      var data = {
        "doctype": doctype,
        ...formValue,
      };

      final response = await dio.post(
        '/method/frappe.desk.form.save.savedocs',
        data: "doc=${Uri.encodeFull(json.encode(data))}&action=Save",
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Router(
                  viewType: ViewType.form,
                  doctype: doctype,
                  name: response.data["docs"][0]["name"]);
            },
          ),
        );
      } else {
        throw Exception('Failed to load album');
      }
    }

    List<Widget> _generateChildren(List fields) {
      List filteredFields = fields.where((field) {
        return (field["read_only"] != 1 ||
                field["fieldtype"] == "Section Break") &&
            field["hidden"] == 0 &&
            [
              "Select",
              "Link",
              "Data",
              "Date",
              "Datetime",
              "Float",
              "Time",
              "Section Break",
              "Text Editor"
            ].contains(
              field["fieldtype"],
            );
      }).toList();

      return generateLayout(
        fields: filteredFields,
        viewType: ViewType.newForm,
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: () async {
              if (_fbKey.currentState.saveAndValidate()) {
                var formValue = _fbKey.currentState.value;
                await _saveForm(
                  widget.meta["name"],
                  formValue,
                );
              }
            },
          ),
        ],
      ),
      body: FormBuilder(
        key: _fbKey,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: ListView(
            padding: EdgeInsets.all(10),
            children: _generateChildren(
              widget.meta["fields"],
            ),
          ),
        ),
      ),
    );
  }
}
