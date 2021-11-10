import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/enums.dart' as enums;
import 'package:frappe_app/utils/form_helper.dart';
import 'package:json_table/json_table.dart';

import 'custom_form.dart';
import 'frappe_button.dart';

class FormBuilderTable<T> extends FormBuilderField<T> {
  FormBuilderTable({
    required String name,
    required BuildContext context,
    required String doctype,
    required T initialValue,
    Key? key,
    FormFieldValidator<T>? validator,
    bool enabled = true,
  }) : super(
          key: key,
          name: name,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<dynamic> field) {
            return FutureBuilder(
              future: locator<Api>().getDoctype(doctype),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var value = (initialValue as List);
                  var metaFields =
                      (snapshot.data as DoctypeResponse).docs[0].fields;
                  var tableFields = metaFields.where((field) {
                    return field.inListView == 1;
                  }).toList();
                  var selectedRowsIdxs = [];

                  var colCount = 3;
                  List<JsonTableColumn> columns = [];
                  var numFields = [];

                  tableFields.forEach(
                    (item) {
                      columns.add(
                        JsonTableColumn(
                          item.fieldname,
                          label: item.label,
                        ),
                      );

                      if (["Float", "Int"].contains(item.fieldtype)) {
                        numFields.add(item.label);
                      }
                    },
                  );

                  colCount =
                      columns.length < colCount ? columns.length : colCount;

                  if (value.isEmpty) {
                    var v = {};

                    tableFields.forEach(
                      (tableField) {
                        v[tableField.fieldname] = "";
                      },
                    );
                    value.add(v);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JsonTable(
                        value,
                        allowRowHighlight: true,
                        rowHighlightColor: FrappePalette.grey[100],
                        onRowHold: (index) {
                          var idx = selectedRowsIdxs.indexOf(index);
                          if (idx != -1) {
                            selectedRowsIdxs.removeAt(idx);
                          } else {
                            selectedRowsIdxs.add(index);
                          }
                        },
                        onRowSelect: (index, val) async {
                          var v = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return TableElement(
                                      doc: val,
                                      fields: tableFields,
                                      meta: (snapshot.data as DoctypeResponse)
                                          .docs[0],
                                    );
                                  },
                                ),
                              ) ??
                              null;

                          if (v != null) {
                            value[index] = v;
                            field.didChange(value);
                          }
                        },
                        tableCellBuilder: (cellValue, index) {
                          var isNum = double.tryParse(cellValue) != null;
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  value.length - 1 == index[0] && index[1] == 0
                                      ? BorderRadius.only(
                                          bottomLeft: Radius.circular(6),
                                        )
                                      : value.length - 1 == index[0] &&
                                              index[1] == colCount - 1
                                          ? BorderRadius.only(
                                              bottomRight: Radius.circular(6),
                                            )
                                          : null,
                              border: Border.all(
                                width: 0.1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                cellValue,
                                textAlign:
                                    isNum ? TextAlign.end : TextAlign.start,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          );
                        },
                        tableHeaderBuilder: (header, index) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width / colCount,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: index == 0
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                      )
                                    : index == columns.length - 1
                                        ? BorderRadius.only(
                                            topRight: Radius.circular(6),
                                          )
                                        : null,
                                border: Border.all(width: 0.1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  header!,
                                  textAlign: numFields.contains(header)
                                      ? TextAlign.end
                                      : TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: FrappePalette.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        columns: columns,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          FrappeFlatButton(
                            onPressed: () {
                              var v = {};
                              tableFields.forEach((tableField) {
                                v[tableField.fieldname] = "";
                              });
                              value.add(v);
                              field.didChange(value);
                            },
                            buttonType: enums.ButtonType.secondary,
                            title: "Add Row",
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          FrappeFlatButton(
                            onPressed: () {
                              selectedRowsIdxs.forEach(
                                (idx) {
                                  value.removeAt(idx);
                                },
                              );
                              selectedRowsIdxs.clear();
                              field.didChange(value);
                            },
                            buttonType: enums.ButtonType.secondary,
                            title: "Delete",
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        );

  @override
  FormBuilderTableState<T> createState() => FormBuilderTableState<T>();
}

class FormBuilderTableState<T>
    extends FormBuilderFieldState<FormBuilderTable<T>, T> {}

class TableElement extends StatefulWidget {
  final DoctypeDoc meta;
  final List<DoctypeField> fields;
  final Map doc;

  TableElement({
    required this.meta,
    required this.doc,
    required this.fields,
  });

  @override
  _TableElementState createState() => _TableElementState();
}

class _TableElementState extends State<TableElement> {
  final formHelper = FormHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8,
            ),
            child: FrappeFlatButton(
              onPressed: () async {
                if (formHelper.saveAndValidate()) {
                  var formValue = formHelper.getFormValue();
                  Navigator.of(context).pop(formValue);
                }
              },
              buttonType: enums.ButtonType.primary,
              title: "Update",
            ),
          ),
        ],
      ),
      body: CustomForm(
        fields: widget.meta.fields,
        formHelper: formHelper,
        doc: widget.doc,
      ),
    );
  }
}
