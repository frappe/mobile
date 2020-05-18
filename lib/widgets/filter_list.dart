import 'package:flutter/material.dart';

import '../utils/helpers.dart';

class FilterList extends StatefulWidget {
  final Function filterCallback;
  final Map wireframe;
  final String appBarTitle;

  FilterList({@required this.filterCallback, @required this.wireframe, @required this.appBarTitle});

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  List<List<String>> filters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                logout(context);
              },
            )
          ],
          title: Text(widget.appBarTitle),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            widget.filterCallback(filters);
          },
          child: Icon(
            Icons.done,
            color: Colors.blueGrey,
          ),
        ),
        body: GridView.count(
            padding: EdgeInsets.all(10),
            childAspectRatio: 2.0,
            crossAxisCount: 2,
            children: widget.wireframe["fields"].where((field) {
              return field["in_standard_filter"] == true;
            }).map<Widget>((field) {
              var val = field["val"];
              return GridTile(
                // header: Text(grid["header"]),
                child: generateChildWidget(field, val, (item) {
                  filters.add([widget.wireframe["doctype"], field["fieldname"], "=", item]);
                  setState(() {
                    field["val"] = item;
                    // formChanged = true;
                  });
                }),
              );
            }).toList()));
  }
}
