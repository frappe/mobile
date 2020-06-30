import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/response_models.dart';
import 'package:frappe_app/utils/rest_apis.dart';

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

  final List<String Function(dynamic)> validators;

  LinkField({
    this.prefixIcon,
    this.fillColor = Palette.fieldBgColor,
    this.allowClear = true,
    this.onSuggestionSelected,
    this.txt,
    this.validators,
    this.showInputBorder = false,
    this.attribute,
    @required this.hint,
    this.value,
    @required this.doctype,
    @required this.refDoctype,
  });

  @override
  _LinkFieldState createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> {
  final TextEditingController _typeAheadController = TextEditingController();

  Future<List> _fetchLinkField(doctype, refDoctype, txt) async {
    var queryParams = {
      'txt': txt,
      'doctype': doctype,
      'reference_doctype': refDoctype,
      'ignore_user_permissions': 0
    };

    var val = await searchLink(queryParams);
    return val.values;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FormBuilderTypeAhead(
        controller: _typeAheadController,
        onSuggestionSelected: (item) {
          if (widget.onSuggestionSelected != null) {
            _typeAheadController.clear();
            widget.onSuggestionSelected(item);
          }
        },
        onChanged: (_) {
          setState(() {
            
          });
        },
        validators: widget.validators,
        decoration: InputDecoration(
          filled: true,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.allowClear ? _typeAheadController.text != '' ? IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () {
              _typeAheadController.clear();
            },
          ) : null : null,
          fillColor: widget.fillColor,
          enabledBorder: !widget.showInputBorder ? InputBorder.none : null,
          hintText: widget.hint,
        ),
        selectionToTextTransformer: (item) {
          if (item is LinkFieldResponse) {
            return item.value;
          } else {
            return item;
          }
        },
        attribute: widget.attribute,
        itemBuilder: (context, item) {
          return ListTile(
            title: Text(
              item.value,
            ),
          );
        },
        initialValue: widget.value,
        suggestionsCallback: (query) {
          var lowercaseQuery = query.toLowerCase();
          return _fetchLinkField(
              widget.doctype, widget.refDoctype, lowercaseQuery);
        },
      ),
    );
  }
}
