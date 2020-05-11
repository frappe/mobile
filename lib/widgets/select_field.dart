import 'package:flutter/material.dart';

class SelectField extends StatefulWidget {
  final options;
  final Function onChanged;
  final value;
  final hint;

  SelectField({this.options, this.onChanged, this.value, this.hint});

  @override
  _SelectFieldState createState() => _SelectFieldState();
}

class _SelectFieldState extends State<SelectField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton(
        value: widget.value,
        onChanged: (dynamic newVal) {
          widget.onChanged(newVal);
        },
        hint: widget.hint,
        items: widget.options.map<DropdownMenuItem>((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }
}
