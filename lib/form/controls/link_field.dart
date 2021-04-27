import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/widgets/form_builder_typeahead.dart';
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
  final Map? doc;

  final key;
  final bool showInputBorder;
  final Function? onSuggestionSelected;
  final Function? noItemsFoundBuilder;
  final Widget? prefixIcon;
  final ItemBuilder? itemBuilder;
  final SuggestionsCallback? suggestionsCallback;
  final AxisDirection direction;
  final bool clearTextOnSelection;

  LinkField({
    this.key,
    required this.doctypeField,
    this.doc,
    this.prefixIcon,
    this.onSuggestionSelected,
    this.noItemsFoundBuilder,
    this.showInputBorder = false,
    this.itemBuilder,
    this.suggestionsCallback,
    this.clearTextOnSelection = false,
    this.direction = AxisDirection.down,
  });

  @override
  _LinkFieldState createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> with Control, ControlInput {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textEditingController.text =
        widget.doc != null ? widget.doc![widget.doctypeField.fieldname] : null;
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

    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.black),
        child: FormBuilderTypeAhead(
          controller: _textEditingController,
          key: widget.key,
          noItemsFoundBuilder: (context) => widget.noItemsFoundBuilder != null
              ? widget.noItemsFoundBuilder!(_textEditingController.text)
              : null,
          direction: AxisDirection.up,
          onSuggestionSelected: (item) {
            if (widget.clearTextOnSelection) {
              setState(() {
                _textEditingController.text = '';
              });
            }
            if (widget.onSuggestionSelected != null) {
              if (item is String) {
                widget.onSuggestionSelected!(item);
              } else if (item is Map) {
                widget.onSuggestionSelected!(item["value"]);
              }
            }
          },
          validator: FormBuilderValidators.compose(validators),
          decoration: Palette.formFieldDecoration(
            label: widget.doctypeField.label,
          ),
          selectionToTextTransformer: (item) {
            if (item != null) {
              if (item is Map) {
                return item["value"];
              }
            }
            return item.toString();
          },
          name: widget.doctypeField.fieldname,
          itemBuilder: widget.itemBuilder ??
              (context, item) {
                if (item is Map) {
                  return ListTile(
                    title: Text(
                      item["value"],
                    ),
                  );
                } else {
                  return ListTile(
                    title: Text(item.toString()),
                  );
                }
              },
          suggestionsCallback: widget.suggestionsCallback ??
              (query) async {
                var lowercaseQuery = query.toLowerCase();
                var isOnline = await verifyOnline();
                if (connectionStatus == ConnectivityStatus.offline &&
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
