import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/widgets/form_builder_typeahead.dart';

import '../../model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

typedef String SelectionToTextTransformer<T>(T selection);

class AutoComplete extends StatefulWidget {
  final DoctypeField doctypeField;

  final Map? doc;
  final void Function(dynamic)? onSuggestionSelected;
  final Widget? prefixIcon;
  final Key? key;
  final ItemBuilder? itemBuilder;
  final SuggestionsCallback? suggestionsCallback;
  final SelectionToTextTransformer? selectionToTextTransformer;
  final InputDecoration? inputDecoration;
  final TextEditingController? controller;

  AutoComplete({
    required this.doctypeField,
    this.doc,
    this.controller,
    this.inputDecoration,
    this.prefixIcon,
    this.key,
    this.onSuggestionSelected,
    this.itemBuilder,
    this.suggestionsCallback,
    this.selectionToTextTransformer,
  });

  @override
  _AutoCompleteState createState() => _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoComplete>
    with Control, ControlInput {
  TextEditingController? _typeAheadController;

  @override
  void initState() {
    _typeAheadController = widget.controller ?? TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String? Function(dynamic?)> validators = [];

    var f = setMandatory(widget.doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.black),
        child: FormBuilderTypeAhead(
          key: widget.key,
          controller: _typeAheadController,
          onSuggestionSelected: widget.onSuggestionSelected,
          onChanged: (_) {
            setState(() {});
          },
          direction: AxisDirection.up,
          validator: FormBuilderValidators.compose(validators),
          decoration: widget.inputDecoration ??
              Palette.formFieldDecoration(
                prefixIcon: widget.prefixIcon,
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
                    item.toString(),
                  ),
                );
              },
          initialValue: widget.doc != null
              ? widget.doc![widget.doctypeField.fieldname]
              : null,
          suggestionsCallback: widget.suggestionsCallback ??
              (query) {
                var lowercaseQuery = query.toLowerCase();
                List opts;
                if (widget.doctypeField.options is String) {
                  opts = widget.doctypeField.options.split('\n');
                } else {
                  opts = widget.doctypeField.options ?? [];
                }
                return opts
                    .where(
                      (option) => option.toLowerCase().contains(
                            lowercaseQuery,
                          ),
                    )
                    .toList();
              },
        ),
      ),
    );
  }
}
