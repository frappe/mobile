// @dart=2.9
import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';

class QueueError extends StatelessWidget {
  final String error;
  final Map dataToUpdate;

  const QueueError({
    Key key,
    @required this.error,
    @required this.dataToUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Palette.bgColor,
            child: Text("Error"),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Text(error),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Palette.bgColor,
            child: Text("Data To Update"),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dataToUpdate.keys.map<Widget>((key) {
                return Text('$key = "${dataToUpdate[key]}"');
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
