import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../datamodels/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

typedef String SelectionToTextTransformer<T>(T selection);

class AutoComplete extends StatefulWidget {
  final DoctypeField doctypeField;
  final Map doc;

  final bool showInputBorder;
  final bool allowClear;
  final Function onSuggestionSelected;
  final Icon prefixIcon;
  final Color fillColor;
  final key;
  final ItemBuilder itemBuilder;
  final SuggestionsCallback suggestionsCallback;
  final SelectionToTextTransformer selectionToTextTransformer;

  AutoComplete({
    @required this.doctypeField,
    @required this.fillColor,
    this.doc,
    this.prefixIcon,
    this.key,
    this.allowClear = true,
    this.onSuggestionSelected,
    this.showInputBorder = false,
    this.itemBuilder,
    this.suggestionsCallback,
    this.selectionToTextTransformer,
  });

  @override
  _AutoCompleteState createState() => _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoComplete>
    with Control, ControlInput {
  final TextEditingController _typeAheadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    validators.add(
      setMandatory(widget.doctypeField, context),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.black),
        child: FormBuilderTypeAhead(
          key: widget.key,
          controller: _typeAheadController,
          onSuggestionSelected: (item) {
            if (widget.onSuggestionSelected != null) {
              widget.onSuggestionSelected(item);
            }
          },
          onChanged: (_) {
            setState(() {});
          },
          validator: FormBuilderValidators.compose(validators),
          decoration: InputDecoration(
            filled: true,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.allowClear
                ? _typeAheadController.text != ''
                    ? IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          _typeAheadController.clear();
                        },
                      )
                    : null
                : null,
            fillColor: widget.fillColor,
            enabledBorder: !widget.showInputBorder ? InputBorder.none : null,
            hintText: widget.doctypeField.label,
          ),
          selectionToTextTransformer: widget.selectionToTextTransformer ??
              (item) {
                return item.toString();
              },
          name: widget.doctypeField.fieldname,
          itemBuilder: widget.itemBuilder ??
              (context, item) {
                return ListTile(
                  title: Text(
                    item,
                  ),
                );
              },
          initialValue: widget.doc[widget.doctypeField.fieldname],
          suggestionsCallback: widget.suggestionsCallback ??
              (query) async {
                var lowercaseQuery = query.toLowerCase();
                return widget.doctypeField.options
                    .split('\n')
                    .where(
                      (option) => option.toLowerCase().contains(lowercaseQuery),
                    )
                    .toList();
              },
        ),
      ),
    );
  }
}
