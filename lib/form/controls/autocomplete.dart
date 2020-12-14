import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

typedef String SelectionToTextTransformer<T>(T selection);

class AutoComplete extends StatefulWidget {
  final String hint;
  final String value;
  final String attribute;
  final String txt;
  final String options;
  final bool showInputBorder;
  final bool allowClear;
  final Function onSuggestionSelected;
  final Icon prefixIcon;
  final Color fillColor;
  final key;
  final ItemBuilder itemBuilder;
  final SuggestionsCallback suggestionsCallback;
  final SelectionToTextTransformer selectionToTextTransformer;

  final List<String Function(dynamic)> validators;

  AutoComplete({
    @required this.hint,
    @required this.fillColor,
    this.prefixIcon,
    this.key,
    this.allowClear = true,
    this.onSuggestionSelected,
    this.txt,
    this.options,
    this.validators,
    this.showInputBorder = false,
    this.attribute,
    this.value,
    this.itemBuilder,
    this.suggestionsCallback,
    this.selectionToTextTransformer,
  });

  @override
  _AutoCompleteState createState() => _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoComplete> {
  final TextEditingController _typeAheadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          validator: FormBuilderValidators.compose(widget.validators),
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
            hintText: widget.hint,
          ),
          selectionToTextTransformer: widget.selectionToTextTransformer ??
              (item) {
                return item.toString();
              },
          name: widget.attribute,
          itemBuilder: widget.itemBuilder ??
              (context, item) {
                return ListTile(
                  title: Text(
                    item,
                  ),
                );
              },
          initialValue: widget.value,
          suggestionsCallback: widget.suggestionsCallback ??
              (query) async {
                var lowercaseQuery = query.toLowerCase();
                return widget.options
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
