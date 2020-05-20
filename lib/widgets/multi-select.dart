import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

import '../utils/response_models.dart';
import '../utils/rest_apis.dart';

class MultiSelect extends StatefulWidget {
  final hint;
  final Function callback;

  final txt;

  MultiSelect({this.callback, @required this.hint, this.txt});

  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  Future _fetchValues(Map data) {
    return getContactList(data);
  }

  Widget _buildAddButton() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Theme.of(context).accentColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.add,
            color: Colors.white,
            size: 15.0,
          ),
          Text(
            "Add User",
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var text = "";

    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlutterTagging(
          textFieldDecoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: widget.hint,
              labelText: widget.hint),
          addButtonWidget: _buildAddButton(),
          chipsColor: Theme.of(context).accentColor,
          chipsFontColor: Colors.white,
          deleteIcon: Icon(Icons.cancel, color: Colors.white),
          chipsPadding: EdgeInsets.all(2.0),
          chipsFontSize: 14.0,
          chipsSpacing: 5.0,
          chipsFontFamily: 'helvetica_neue_light',
          suggestionsCallback: (pattern) async {
            if (pattern == '') {
              pattern = 'a';
            }
            var val = await _fetchValues({"txt": pattern});
            if (val.values.length == 0) {
              val = DioLinkFieldResponse.fromJson({
                "results": [
                  {"value": pattern}
                ]
              });
            }
            var d = val.values.map((v) => {"name": v.value});
            return d;
          },
          onChanged: (result) {
            setState(() {
              result.forEach((r) {
                text += '${r["name"]},';
              });
              widget.callback(text);
            });
          },
        ),
      ),
    ]);
  }
}
