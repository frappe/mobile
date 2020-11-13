import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';

import '../utils/config_helper.dart';
import '../services/backend_service.dart';
import '../utils/enums.dart';

import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';

class AddReview extends StatefulWidget {
  final String doctype;
  final String name;
  final DoctypeDoc meta;
  final Map doc;
  final Map docInfo;

  const AddReview({
    Key key,
    @required this.doctype,
    @required this.name,
    @required this.meta,
    @required this.doc,
    @required this.docInfo,
  }) : super(key: key);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  var wireframe;

  void initState() {
    super.initState();
    wireframe = [
      {
        "fieldname": 'to_user',
        "fieldtype": 'Autocomplete',
        "label": 'To User',
        "reqd": 1,
        "options": getInvolvedUsers(),
        "ignore_validation": 1,
        "description": 'Only users involved in the document are listed'
      },
      {
        "fieldname": 'review_type',
        "fieldtype": 'Select',
        "label": 'Action',
        "options": ['Appreciation', 'Criticism'],
        "default": 'Appreciation'
      },
      {
        "fieldname": 'points',
        "fieldtype": 'Int',
        "label": 'Points',
        "reqd": 1,
        // "description": "Currently you have ${this.points.review_points} review points".
      },
      {
        "fieldtype": 'Small Text',
        "fieldname": 'reason',
        "reqd": 1,
        "label": 'Reason',
      }
    ];
  }

  getInvolvedUsers() {
    var userFields = widget.meta.fields
        .where((d) => d.fieldtype == 'Link' && d.options == 'User')
        .map((d) => d.fieldname)
        .toList();

    userFields.add('owner');
    var involvedUsers = userFields.map((field) => widget.doc[field]).toList();

    var a = widget.docInfo["communications"]
        .where((d) => d["sender"] != null && d["delivery_status"] == 'sent')
        .map((d) => d["sender"])
        .toList();
    a.addAll(widget.docInfo["comments"].map((d) => d["owner"]).toList());
    a.addAll(widget.docInfo["versions"].map((d) => d["owner"]).toList());
    a.addAll(widget.docInfo["assignments"]
        .map(
          (d) => d["owner"],
        )
        .toList());
    involvedUsers.addAll(a);

    return involvedUsers
        .toSet()
        .toList()
        .where(
            (user) => !['Administrator', ConfigHelper().userId].contains(user))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 4,
            ),
            child: FrappeFlatButton(
              onPressed: () async {
                if (_fbKey.currentState.saveAndValidate()) {
                  var formValue = _fbKey.currentState.value;
                  await BackendService.addReview(
                    widget.doctype,
                    widget.name,
                    formValue,
                  );

                  Navigator.of(context).pop(true);
                }
              },
              buttonType: ButtonType.primary,
              title: 'Submit',
            ),
          )
        ],
      ),
      body: CustomForm(
        fields: wireframe,
        formKey: _fbKey,
        viewType: ViewType.newForm,
      ),
    );
  }
}
