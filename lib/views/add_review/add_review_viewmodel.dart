import 'package:flutter/foundation.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';
import 'package:frappe_app/utils/config_helper.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AddReviewViewModel extends BaseViewModel {
  List<DoctypeField> fields;

  getReviewFormFields({
    @required DoctypeDoc meta,
    @required Map docInfo,
    @required Map doc,
  }) {
    fields = [
      DoctypeField(
          fieldname: 'to_user',
          fieldtype: 'Autocomplete',
          label: 'To User',
          reqd: 1,
          options: getInvolvedUsers(
            meta: meta,
            doc: doc,
            docInfo: docInfo,
          )),
      DoctypeField(
          fieldname: 'review_type',
          fieldtype: 'Select',
          label: 'Action',
          options: ['Appreciation', 'Criticism'],
          defaultValue: 'Appreciation'),
      DoctypeField(
        fieldname: 'points',
        fieldtype: 'Int',
        label: 'Points',
        reqd: 1,
        // description: Currently you have ${this.points.review_points} review points.
      ),
      DoctypeField(
        fieldtype: 'Small Text',
        fieldname: 'reason',
        reqd: 1,
        label: 'Reason',
      ),
    ];
  }

  getInvolvedUsers({
    @required DoctypeDoc meta,
    @required Map docInfo,
    @required Map doc,
  }) {
    var userFields = meta.fields
        .where((d) => d.fieldtype == 'Link' && d.options == 'User')
        .map((d) => d.fieldname)
        .toList();

    userFields.add('owner');
    var involvedUsers = userFields.map((field) => doc[field]).toList();

    var a = docInfo["communications"]
        .where((d) => d["sender"] != null && d["delivery_status"] == 'sent')
        .map((d) => d["sender"])
        .toList();
    a.addAll(docInfo["comments"].map((d) => d["owner"]).toList());
    a.addAll(docInfo["versions"].map((d) => d["owner"]).toList());
    a.addAll(docInfo["assignments"]
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
}
