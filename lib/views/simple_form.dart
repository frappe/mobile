import 'dart:convert';
import 'dart:typed_data';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../datamodels/doctype_response.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../utils/enums.dart';
import '../utils/frappe_alert.dart';
import '../utils/queue_helper.dart';
import '../utils/helpers.dart';

import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';

class SimpleForm extends StatefulWidget {
  final DoctypeDoc meta;

  SimpleForm(this.meta);

  @override
  _SimpleFormState createState() => _SimpleFormState();
}

class _SimpleFormState extends State<SimpleForm> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("New ${widget.meta.name}"),
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

                  formValue.forEach((key, value) {
                    if (value is Uint8List) {
                      formValue[key] =
                          "data:image/png;base64,${base64.encode(value)}";
                    }
                  });

                  var isOnline = await verifyOnline();
                  if ((connectionStatus == null ||
                          connectionStatus == ConnectivityStatus.offline) &&
                      !isOnline) {
                    var qc = QueueHelper.getQueueContainer();
                    var queueLength = qc.length;
                    var qObj = {
                      "type": "Create",
                      "doctype": widget.meta.name,
                      "title": hasTitle(widget.meta)
                          ? formValue[widget.meta.titleField] ??
                              "${widget.meta.name} ${queueLength + 1}"
                          : "${widget.meta.name} ${queueLength + 1}",
                      "data": [formValue],
                    };
                    await QueueHelper.add(qObj);

                    FrappeAlert.infoAlert(
                      title: 'No Internet Connection',
                      subtitle: 'Added to Queue',
                      context: context,
                    );
                    locator<NavigationService>().pop();
                  } else {
                    try {
                      var response = await locator<Api>().saveDocs(
                        widget.meta.name,
                        formValue,
                      );
                      locator<NavigationService>().pushReplacement(
                        Routes.customRouter,
                        arguments: CustomRouterArguments(
                          viewType: ViewType.form,
                          doctype: widget.meta.name,
                          name: response.data["docs"][0]["name"],
                        ),
                      );
                    } catch (e) {
                      showErrorDialog(e, context);
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
      body: CustomForm(
        formKey: _fbKey,
        fields: widget.meta.fields,
        viewType: ViewType.newForm,
      ),
    );
  }
}
