import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/list_view/bottom_sheets/edit_filter_bottom_sheet_viewmodel.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

class EditFilterBottomSheetView extends StatelessWidget {
  final int page;
  final DoctypeResponse meta;

  const EditFilterBottomSheetView({
    @required this.page,
    this.meta,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<EditFilterBottomSheetViewModel>(
      onModelReady: (model) {
        model.pageNumber = page;
        model.filter = [null, "Equals", ""];
      },
      onModelClose: (model) {
        model.filter.clear();
      },
      builder: (context, model, child) {
        Widget widget;
        if (model.pageNumber == 1) {
          widget = SelectFilterField(
            meta: meta,
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
            onActionButtonPress: (dynamic val) {
              Navigator.of(context).pop(val);
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
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FrappeBottomSheet(
      title: 'Edit Value',
      leadingText: 'Back',
      leadingOnPressed: widget.leadingOnPressed,
      trailing: Text(
        'Done',
        style: TextStyle(
          color: FrappePalette.blue[500],
        ),
      ),
      onActionButtonPress: () {
        widget.model.addFilterValue(page: 3, value: textEditingController.text);
        widget.onActionButtonPress(widget.model.filter);
      },
      body: Column(
        children: [
          TextField(
            controller: textEditingController,
            autofocus: true,
            decoration: Palette.formFieldDecoration(
              label: "",
              withLabel: false,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectFilterField extends StatelessWidget {
  final Function onActionButtonPress;
  final Function leadingOnPressed;
  final DoctypeResponse meta;
  final EditFilterBottomSheetViewModel model;

  SelectFilterField({
    this.onActionButtonPress,
    this.leadingOnPressed,
    @required this.meta,
    @required this.model,
  });

  @override
  Widget build(BuildContext context) {
    var fields = meta.docs[0].fields.where((field) {
      return field.fieldtype == "Section Break" || field.hidden != 1;
    }).map((field) {
      return field.fieldname;
    });
    return FrappeBottomSheet(
      title: 'Choose filter field',
      showLeading: false,
      trailing: Text(
        'Done',
        style: TextStyle(
          color: FrappePalette.blue[500],
        ),
      ),
      onActionButtonPress: onActionButtonPress,
      body: ListView(
          children: fields.map((field) {
        return ListTile(
          onTap: () {
            model.addFilterValue(page: 1, value: field);
            model.moveToPage(2);
          },
          visualDensity: VisualDensity(vertical: -4),
          title: Text(
            field,
            style: TextStyle(
              color: FrappePalette.grey[700],
            ),
          ),
          trailing: FrappeIcon(
            FrappeIcons.arrow_right,
            size: 18,
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
        'Done',
        style: TextStyle(
          color: FrappePalette.blue[500],
        ),
      ),
      leadingOnPressed: leadingOnPressed,
      leadingText: "Back",
      onActionButtonPress: onActionButtonPress,
      title: 'Choose filter operator',
      body: ListView(
          children: model.operators.map((opt) {
        return ListTile(
          onTap: () {
            model.addFilterValue(page: 2, value: opt);
            model.moveToPage(3);
          },
          visualDensity: VisualDensity(vertical: -4),
          title: Text(
            opt,
            style: TextStyle(
              color: FrappePalette.grey[700],
            ),
          ),
          trailing: FrappeIcon(
            FrappeIcons.arrow_right,
            size: 18,
          ),
        );
      }).toList()),
    );
  }
}
