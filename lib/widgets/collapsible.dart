import 'package:flutter/material.dart';
// import 'package:support_app/widgets/link_field.dart';
import 'package:support_app/widgets/multi-select.dart';

class Collapsible extends StatefulWidget {
  final String header;
  // final List items;
  final Function callback;

  Collapsible(this.header, this.callback);

  @override
  _CollapsibleState createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  var dropdownVal;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text(widget.header),
        children: <Widget>[
          MultiSelect(
            hint: "CC",
            onSuggestionSelected: (item) {
              widget.callback({"cc": item});
            },
          ),
          MultiSelect(
            hint: "BCC",
            onSuggestionSelected: (item) {
              widget.callback({"bcc": item});
            },
          ),
          // LinkField(
            // doctype: "Email Template",
            // hint: "Email Template",
            // refDoctype: "Issue",
            // value: dropdownVal,
            // onSuggestionSelected: (item) {
            //   setState(() {
            //     dropdownVal = item;
            //   }); 
            //   widget.callback({"email template": item});
            // })
        ],
      
    );
  }
}
