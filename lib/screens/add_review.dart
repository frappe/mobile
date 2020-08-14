import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';

class AddReview extends StatefulWidget {
  final String doctype;
  final String name;

  const AddReview({
    Key key,
    @required this.doctype,
    @required this.name,
  }) : super(key: key);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  BackendService backendService;
  var wireframe;

  void initState() {
    super.initState();
    backendService = BackendService(context);
    wireframe = [
      {
        "fieldname": 'to_user',
        "fieldtype": 'Link',
        "label": 'To User',
        "reqd": 1,
        "options": 'User',
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
                  await backendService.addReview(
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
