import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import '../../model/doctype_response.dart';
import '../../app/locator.dart';
import '../../services/api/api.dart';

import '../../utils/helpers.dart';
import '../../model/offline_storage.dart';
import '../../utils/enums.dart';

import 'base_control.dart';
import 'base_input.dart';

class LinkField extends StatefulWidget {
  final DoctypeField doctypeField;
  final Map doc;

  final key;
  final bool withLabel;
  final bool showInputBorder;
  final bool allowClear;
  final Function onSuggestionSelected;
  final Icon prefixIcon;
  final Color fillColor;
  final ItemBuilder itemBuilder;
  final SuggestionsCallback suggestionsCallback;

  final List<String Function(dynamic)> validators;

  LinkField({
    this.key,
    @required this.doctypeField,
    @required this.fillColor,
    this.withLabel = true,
    this.doc,
    this.prefixIcon,
    this.allowClear = true,
    this.onSuggestionSelected,
    this.validators,
    this.showInputBorder = false,
    this.itemBuilder,
    this.suggestionsCallback,
  });

  @override
  _LinkFieldState createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> with Control, ControlInput {
  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    var f = setMandatory(widget.doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.black),
        child: FormBuilderTypeAhead(
          key: widget.key,
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
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: const BorderRadius.all(
                const Radius.circular(6),
              ),
            ),
            prefixIcon: widget.prefixIcon,
            fillColor: widget.fillColor,
            hintText: widget.withLabel ? null : widget.doctypeField.label,
          ),
          selectionToTextTransformer: (item) {
            if (item != null) {
              if (item is Map) {
                return item["value"];
              }
            }
            return item;
          },
          name: widget.doctypeField.fieldname,
          itemBuilder: widget.itemBuilder ??
              (context, item) {
                return ListTile(
                  title: Text(
                    item["value"],
                  ),
                );
              },
          initialValue: widget.doc != null
              ? widget.doc[widget.doctypeField.fieldname]
              : null,
          suggestionsCallback: widget.suggestionsCallback ??
              (query) async {
                var lowercaseQuery = query.toLowerCase();
                var isOnline = await verifyOnline();
                if ((connectionStatus == null ||
                        connectionStatus == ConnectivityStatus.offline) &&
                    !isOnline) {
                  var linkFull = await OfflineStorage.getItem(
                      '${widget.doctypeField.options}LinkFull');
                  linkFull = linkFull["data"];

                  if (linkFull != null) {
                    return linkFull["results"].where(
                      (link) {
                        return (link["value"] as String)
                            .toLowerCase()
                            .contains(lowercaseQuery);
                      },
                    ).toList();
                  } else {
                    var queryLink = await OfflineStorage.getItem(
                        '$lowercaseQuery${widget.doctypeField.options}Link');
                    queryLink = queryLink["data"];

                    if (queryLink != null) {
                      return queryLink["results"];
                    } else {
                      return [];
                    }
                  }
                } else {
                  var response = await locator<Api>().searchLink(
                    doctype: widget.doctypeField.options,
                    txt: lowercaseQuery,
                  );

                  return response["results"];
                }
              },
        ),
      ),
    );
  }
}
