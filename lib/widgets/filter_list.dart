import 'package:flutter/material.dart';
import 'package:support_app/utils/helpers.dart';

class FilterList extends StatefulWidget {
  final Function filterCallback;
  final Map wireframe;

  FilterList({@required this.filterCallback, @required this.wireframe});

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  Map filterObj = {};

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
          title: Text(widget.wireframe['appBarTitle']),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            widget.filterCallback(filterObj);
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
            children: widget.wireframe["grids"].where((grid) {
              return grid["widget"]["in_standard_filter"] == true;
            }).map<Widget>((grid) {
              Map widget = grid["widget"];

              var val = widget["val"];
              return GridTile(
                // header: Text(grid["header"]),
                child: generateChildWidget(widget, val, (item) {
                  filterObj[widget["fieldname"]] = item;
                  setState(() {
                    widget["val"] = item;
                    // formChanged = true;
                  });
                }),
              );
            }).toList()));
  }
}
