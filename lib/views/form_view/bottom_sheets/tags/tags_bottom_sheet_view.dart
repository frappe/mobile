// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/link_field.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/frappe_alert.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';

import 'package:frappe_app/views/form_view/bottom_sheets/tags/tags_bottom_sheet_viewmodel.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

class TagsBottomSheetView extends StatefulWidget {
  final String doctype;
  final String name;
  final List tags;
  final Function refreshCallback;

  const TagsBottomSheetView({
    Key key,
    @required this.doctype,
    @required this.name,
    @required this.tags,
    @required this.refreshCallback,
  }) : super(key: key);

  @override
  _TagsBottomSheetViewState createState() => _TagsBottomSheetViewState();
}

class _TagsBottomSheetViewState extends State<TagsBottomSheetView> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseView<TagsBottomSheetViewModel>(
      onModelClose: (model) {},
      onModelReady: (model) {
        model.currentTags = widget.tags;
      },
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.5,
        child: FrappeBottomSheet(
          title: 'Tags',
          body: Column(
            children: [
              FormBuilder(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LinkField(
                    controller: _controller,
                    direction: AxisDirection.up,
                    noItemsFoundBuilder: (query) {
                      return ListTile(
                        onTap: () async {
                          await model.addTag(
                            doctype: widget.doctype,
                            name: widget.name,
                            tag: query,
                          );

                          widget.refreshCallback();

                          FocusScope.of(context).unfocus();
                        },
                        title: Row(
                          children: [
                            FrappeIcon(
                              FrappeIcons.tag,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Create',
                              style: TextStyle(
                                color: FrappePalette.grey,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '"$query"',
                            ),
                          ],
                        ),
                      );
                    },
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: FrappeIcon(
                            FrappeIcons.search,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                    doctypeField: DoctypeField(
                      label: 'Search or create tags here',
                      fieldname: "tags",
                    ),
                    onSuggestionSelected: (selectedTag) async {
                      await model.addTag(
                        doctype: widget.doctype,
                        name: widget.name,
                        tag: selectedTag,
                      );

                      _controller.clear();

                      widget.refreshCallback();
                    },
                    itemBuilder: (context, item) {
                      return ListTile(
                        title: Text(item),
                      );
                    },
                    suggestionsCallback: (query) async {
                      return await model.getTags(
                        doctype: widget.doctype,
                        query: query,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: _generateChildren(
                    model: model,
                    context: context,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _generateChildren({
    @required TagsBottomSheetViewModel model,
    BuildContext context,
  }) {
    return model.currentTags.asMap().entries.map<Widget>(
      (entry) {
        var tag = entry.value;
        var index = entry.key;
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
            left: 8,
            right: 8,
          ),
          child: ListTile(
            visualDensity: VisualDensity(
              horizontal: 0,
              vertical: -4,
            ),
            contentPadding: EdgeInsets.only(
              left: 10,
            ),
            tileColor: FrappePalette.grey[100],
            title: Text(
              tag,
              style: TextStyle(
                color: FrappePalette.grey[700],
              ),
            ),
            trailing: IconButton(
              icon: FrappeIcon(
                FrappeIcons.close_alt,
                size: 13,
              ),
              onPressed: () async {
                try {
                  await model.removeTag(
                    doctype: widget.doctype,
                    name: widget.name,
                    tag: tag,
                    index: index,
                  );

                  FrappeAlert.infoAlert(
                    context: context,
                    title: "$tag has been removed",
                  );

                  widget.refreshCallback();
                } catch (e) {
                  print(e);
                }
              },
            ),
          ),
        );
      },
    ).toList();
  }
}
