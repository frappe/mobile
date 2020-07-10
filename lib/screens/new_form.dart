import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';

import '../app.dart';

class NewForm extends StatefulWidget {
  final Map meta;

  NewForm(this.meta);

  @override
  _NewFormState createState() => _NewFormState();
}

class _NewFormState extends State<NewForm> {
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

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
                var response = await backendService.saveDocs(
                  widget.meta["name"],
                  formValue,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Router(
                          viewType: ViewType.form,
                          doctype: widget.meta["name"],
                          name: response.data["docs"][0]["name"]);
                    },
                  ),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: _generateChildren(
                  widget.meta["fields"],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
