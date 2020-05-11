import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:support_app/utils/response_models.dart';
import 'package:support_app/utils/rest_apis.dart';


class MultiSelect extends StatefulWidget {
  final value;
  final hint;
  final Function onSuggestionSelected;

  final doctype;
  final refDoctype;
  final txt;

  MultiSelect(
      {this.value,
      this.onSuggestionSelected,
      @required this.hint,
      this.doctype,
      this.refDoctype,
      this.txt});

  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  String dropdownVal;
  final TextEditingController _typeAheadController = TextEditingController();
  var queryParams = {};
  var selectedValues = [];

  Future _fetchValues(Map data) {
    return get_contact_list(data);
  }

  Widget _buildAddButton() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Colors.pinkAccent,
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
            "Add New Tag",
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
          chipsColor: Colors.pinkAccent,
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
            if(val.values.length == 0) {
              val = DioLinkFieldResponse.fromJson({"results": [{"value": pattern}]});
            }
            var d = val.values.map((v) => {"name": v.value});
            return d;
          },
          onChanged: (result) {
            setState(() {
              result.forEach((r) {
                text += '${r["name"]},';
              });
              widget.onSuggestionSelected(text);
            });
          },
        ),
      ),
    ]);
  }
}
