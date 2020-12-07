import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/services/backend_service.dart';

import 'package:json_table/json_table.dart';

class CustomTable extends StatelessWidget {
  final String doctype;
  final List items;

  const CustomTable({
    Key key,
    @required this.doctype,
    @required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return Container();
    }
    return FutureBuilder(
      future: BackendService.getDoctype(doctype),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var colCount = 3;
          List<JsonTableColumn> columns = [];
          var numFields = [];

          List metaFields = snapshot.data["docs"][0]["fields"];
          var tableFields = metaFields.where((field) {
            return field["in_list_view"] == 1;
          }).toList();

          tableFields.forEach(
            (item) {
              columns.add(
                JsonTableColumn(
                  item["fieldname"],
                  label: item["label"],
                ),
              );

              if (["Float", "Int"].contains(item["fieldtype"])) {
                numFields.add(item["label"]);
              }
            },
          );

          colCount = columns.length < colCount ? columns.length : colCount;

          return JsonTable(
            items,
            tableCellBuilder: (value) {
              var isNum = double.tryParse(value) != null;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(6),
                  ),
                  border: Border.all(
                    width: 0.1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    textAlign: isNum ? TextAlign.end : TextAlign.start,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              );
            },
            tableHeaderBuilder: (header) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width / colCount,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(6),
                    ),
                    border: Border.all(width: 0.1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      header,
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
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
