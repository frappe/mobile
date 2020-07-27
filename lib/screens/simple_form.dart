import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/widgets/custom_form.dart';

import '../app.dart';

class SimpleForm extends StatefulWidget {
  final Map meta;

  SimpleForm(this.meta);

  @override
  _SimpleFormState createState() => _SimpleFormState();
}

class _SimpleFormState extends State<SimpleForm> {
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

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
      body: CustomForm(
        formKey: _fbKey,
        fields: widget.meta["fields"],
        viewType: ViewType.newForm,
      ),
    );
  }
}
