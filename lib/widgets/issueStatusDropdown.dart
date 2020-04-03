import 'package:flutter/material.dart';

class IssueStatusDropdown extends StatefulWidget {
  final value;
  final Function onChanged;

  IssueStatusDropdown({
    this.value,
    this.onChanged
  });

  @override
  _IssueStatusDropdownState createState() => _IssueStatusDropdownState();
}

class _IssueStatusDropdownState extends State<IssueStatusDropdown> {
  String dropdownVal;

  // @override
  // void initState() {
  //   super.initState();
  //   dropdownVal = widget.value;
  // }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: widget.value,
      onChanged: (dynamic newVal) {
        widget.onChanged(newVal);
      },
      hint: Text('Status'),
      items: <String>['Open', 'Pending', 'Closed']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}