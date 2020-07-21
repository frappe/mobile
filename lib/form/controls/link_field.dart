import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import './../../config/palette.dart';
import './../../utils/backend_service.dart';

class LinkField extends StatefulWidget {
  final String hint;
  final String value;
  final String attribute;
  final String doctype;
  final String refDoctype;
  final String txt;
  final bool showInputBorder;
  final bool allowClear;
  final Function onSuggestionSelected;
  final Icon prefixIcon;
  final Color fillColor;
  final key;

  final List<String Function(dynamic)> validators;

  LinkField({
    @required this.hint,
    @required this.doctype,
    @required this.refDoctype,
    @required this.fillColor,
    this.prefixIcon,
    this.key,
    this.allowClear = true,
    this.onSuggestionSelected,
    this.txt,
    this.validators,
    this.showInputBorder = false,
    this.attribute,
    this.value,
  });

  @override
  _LinkFieldState createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> {
  final TextEditingController _typeAheadController = TextEditingController();
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
  }

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
              _typeAheadController.clear();
              widget.onSuggestionSelected(item);
            }
          },
          onChanged: (_) {
            setState(() {});
          },
          validators: widget.validators,
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
          selectionToTextTransformer: (item) {
            if (item != null) {
              if (item is Map) {
                return item["value"];
              }
            }
            return item;
          },
          attribute: widget.attribute,
          itemBuilder: (context, item) {
            return ListTile(
              title: Text(
                item["value"],
              ),
            );
          },
          initialValue: widget.value,
          suggestionsCallback: (query) async {
            var lowercaseQuery = query.toLowerCase();
            var response = await backendService.searchLink(
              widget.doctype,
              widget.refDoctype,
              lowercaseQuery,
            );

            return response["results"];
          },
        ),
      ),
    );
  }
}
