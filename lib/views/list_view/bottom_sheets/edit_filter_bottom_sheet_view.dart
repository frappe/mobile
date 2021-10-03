// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/form/controls/select.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/constants.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/list_view/bottom_sheets/edit_filter_bottom_sheet_viewmodel.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

class EditFilterBottomSheetView extends StatelessWidget {
  final int page;
  final List<DoctypeField> fields;
  final Filter filter;

  const EditFilterBottomSheetView({
    @required this.page,
    this.fields,
    this.filter,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<EditFilterBottomSheetViewModel>(
      onModelReady: (model) {
        model.pageNumber = page;
        model.filter = filter;
      },
      builder: (context, model, child) {
        Widget widget;
        if (model.pageNumber == 1) {
          widget = SelectFilterField(
            fields: fields,
            model: model,
            onActionButtonPress: () {
              model.moveToPage(2);
            },
          );
        } else if (model.pageNumber == 2) {
          widget = SelectFilterOperator(
            model: model,
            leadingOnPressed: () {
              model.moveToPage(1);
            },
            onActionButtonPress: () {
              model.moveToPage(3);
            },
          );
        } else if (model.pageNumber == 3) {
          widget = EditValue(
            model: model,
            leadingOnPressed: () {
              model.moveToPage(2);
            },
            onActionButtonPress: (Filter filter) {
              Navigator.of(context).pop(filter);
            },
          );
        }
        return FractionallySizedBox(
          heightFactor: 0.55,
          child: widget,
        );
      },
    );
  }
}

class SelectFilterField extends StatelessWidget {
  final Function onActionButtonPress;
  final Function leadingOnPressed;
  final List<DoctypeField> fields;
  final EditFilterBottomSheetViewModel model;

  SelectFilterField({
    this.onActionButtonPress,
    this.leadingOnPressed,
    @required this.fields,
    @required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return FrappeBottomSheet(
      title: 'Choose filter field',
      trailing: Text(
        model.filter.isInit ? 'Next' : 'Done',
        style: TextStyle(
          color: FrappePalette.blue[500],
        ),
      ),
      onActionButtonPress: () {
        if (model.filter.isInit) {
          model.moveToPage(2);
        } else {
          Navigator.of(context).pop(model.filter);
        }
      },
      body: ListView(
          children: fields.map((field) {
        return Container(
          color: field.fieldname == model.filter.field.fieldname
              ? FrappePalette.grey[100]
              : null,
          child: ListTile(
            onTap: () {
              model.updateFieldName(field);
            },
            visualDensity: VisualDensity(vertical: -4),
            title: Text(
              field.label,
              style: TextStyle(
                color: FrappePalette.grey[700],
              ),
            ),
            trailing: FrappeIcon(
              FrappeIcons.arrow_right,
              size: 18,
            ),
          ),
        );
      }).toList()),
    );
  }
}

class SelectFilterOperator extends StatelessWidget {
  final Function onActionButtonPress;
  final Function leadingOnPressed;
  final EditFilterBottomSheetViewModel model;

  SelectFilterOperator({
    this.onActionButtonPress,
    this.leadingOnPressed,
    this.model,
  });

  @override
  Widget build(BuildContext context) {
    return FrappeBottomSheet(
      trailing: Text(
        model.filter.isInit ? 'Next' : 'Done',
        style: TextStyle(
          color: FrappePalette.blue[500],
        ),
      ),
      leadingOnPressed: model.filter.isInit ? leadingOnPressed : null,
      leadingText: model.filter.isInit ? "Back" : null,
      onActionButtonPress: () {
        if (model.filter.isInit) {
          model.moveToPage(3);
        } else {
          Navigator.of(context).pop(model.filter);
        }
      },
      title: 'Choose filter operator',
      body: ListView(
          children: Constants.filterOperators.where((opt) {
        if (model.filter.field.fieldtype == "Check") {
          if (opt.label == "Equals") {
            return true;
          } else {
            return false;
          }
        } else if (model.filter.field.fieldname == "_assign" ||
            model.filter.field.fieldname == "owner") {
          if (opt.label == "Like") {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      }).map(
        (opt) {
          return Container(
            color: opt == model.filter.filterOperator
                ? FrappePalette.grey[100]
                : null,
            child: ListTile(
              onTap: () {
                model.updateFilterOperator(opt);
              },
              visualDensity: VisualDensity(vertical: -4),
              title: Text(
                opt.label,
                style: TextStyle(
                  color: FrappePalette.grey[700],
                ),
              ),
              trailing: FrappeIcon(
                FrappeIcons.arrow_right,
                size: 18,
              ),
            ),
          );
        },
      ).toList()),
    );
  }
}

class EditValue extends StatefulWidget {
  final Function onActionButtonPress;
  final Function leadingOnPressed;
  final EditFilterBottomSheetViewModel model;

  EditValue({
    this.onActionButtonPress,
    this.leadingOnPressed,
    this.model,
  });

  @override
  _EditValueState createState() => _EditValueState();
}

class _EditValueState extends State<EditValue> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return FrappeBottomSheet(
      title: 'Edit Value',
      leadingText: widget.model.filter.isInit ? 'Back' : null,
      leadingOnPressed:
          widget.model.filter.isInit ? widget.leadingOnPressed : null,
      trailing: Text(
        'Done',
        style: TextStyle(
          color: FrappePalette.blue[500],
        ),
      ),
      onActionButtonPress: () {
        _fbKey.currentState.save();
        var v = _fbKey.currentState.value[widget.model.filter.field.fieldname];
        widget.model.updateValue(v);
        widget.onActionButtonPress(widget.model.filter);
      },
      body: Column(
        children: [
          FormBuilder(
            key: _fbKey,
            child: Builder(builder: (context) {
              if (widget.model.filter.field.fieldtype == "Check") {
                widget.model.filter.field.options = ["Yes", "No"];
                return Select(
                  doctypeField: widget.model.filter.field,
                  doc: {
                    "${widget.model.filter.field.fieldname}":
                        widget.model.filter.value
                  },
                );
              } else {
                return makeControl(
                  field: widget.model.filter.field,
                  doc: {
                    widget.model.filter.field.fieldname: "",
                  },
                );
              }
            }),
          )
        ],
      ),
    );
  }
}
