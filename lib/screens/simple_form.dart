import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import '../app.dart';

import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/frappe_alert.dart';
import '../utils/queue_helper.dart';

import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';

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
    backendService = BackendService();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 4,
            ),
            child: FrappeFlatButton(
              buttonType: ButtonType.primary,
              title: 'Save',
              onPressed: () async {
                if (_fbKey.currentState.saveAndValidate()) {
                  var formValue = _fbKey.currentState.value;

                  if (connectionStatus == ConnectivityStatus.offline) {
                    QueueHelper.add({
                      "type": "create",
                      "doctype": widget.meta["name"],
                      "title": formValue[widget.meta["title_field"]],
                      "data": [formValue],
                    });

                    FrappeAlert.infoAlert(
                      title: 'No Internet Connection',
                      subtitle: 'Added to Queue',
                      context: context,
                    );
                  } else {
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
                }
              },
            ),
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
