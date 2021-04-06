import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';

import 'package:frappe_app/views/list_view/bottom_sheets/edit_filter_bottom_sheet_view.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/frappe_button.dart';

import 'filters_bottom_sheet_viewmodel.dart';

class FiltersBottomSheetView extends StatelessWidget {
  final DoctypeResponse meta;

  const FiltersBottomSheetView({
    Key key,
    @required this.meta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<FiltersBottomSheetViewModel>(
      onModelReady: (model) {
        model.filtersToApply.add(
          [
            null,
            "Equals",
            "",
          ],
        );
      },
      onModelClose: (model) {
        model.filtersToApply.clear();
      },
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.8,
        child: FrappeBottomSheet(
          title: 'Filters',
          bottomBar: Container(
            color: Colors.white,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 18.0,
                    right: 18.0,
                    bottom: 30,
                  ),
                  child: FrappeFlatButton(
                    buttonType: ButtonType.secondary,
                    onPressed: () {
                      model.addFilter();
                    },
                    title: 'Add Filter',
                    icon: FrappeIcons.small_add,
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 18.0,
                    right: 18.0,
                    bottom: 30,
                  ),
                  child: FrappeFlatButton(
                    buttonType: ButtonType.primary,
                    onPressed: () {},
                    title: 'Apply',
                  ),
                ),
              ],
            ),
          ),
          onActionButtonPress: () {
            model.clearFilters();
          },
          trailing: Row(
            children: [
              Text(
                'Clear Filters',
                style: TextStyle(
                  color: FrappePalette.red[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          body: ListView(
            children: model.filtersToApply.asMap().entries.map(
              (entry) {
                var filter = entry.value;
                var idx = entry.key;

                return AddFilter(
                  meta: meta,
                  model: model,
                  onDelete: () {
                    model.removeFilter(idx);
                  },
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}

class AddFilter extends StatelessWidget {
  final DoctypeResponse meta;
  final FiltersBottomSheetViewModel model;
  final Function onDelete;

  const AddFilter({
    Key key,
    @required this.meta,
    @required this.model,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 52,
          child: Wrap(
            children: [
              FlatButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  List val = await showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => EditFilterBottomSheetView(
                          page: 1,
                          meta: meta,
                        ),
                      ) ??
                      false;

                  if (val.isNotEmpty) {
                    // refreshCallback();
                  }
                },
                child: Container(
                  color: FrappePalette.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 110,
                          ),
                          child: Text(
                            'name',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: FrappePalette.grey[600],
                            ),
                          ),
                        ),
                        FrappeIcon(
                          FrappeIcons.select,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 4,
                ),
                child: Text('field'),
              ),
              SizedBox(
                width: 8,
              ),
              FlatButton(
                onPressed: () async {
                  bool refresh = await showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => EditFilterBottomSheetView(
                          page: 2,
                        ),
                      ) ??
                      false;

                  if (refresh) {
                    // refreshCallback();
                  }
                },
                padding: EdgeInsets.zero,
                child: Container(
                  color: FrappePalette.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Equals',
                          style: TextStyle(
                            color: FrappePalette.grey[600],
                          ),
                        ),
                        FrappeIcon(
                          FrappeIcons.select,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: FrappePalette.grey[100],
                    borderRadius: BorderRadius.circular(
                      6,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      bool refresh = await showModalBottomSheet(
                            useRootNavigator: true,
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => EditFilterBottomSheetView(
                              page: 3,
                            ),
                          ) ??
                          false;

                      if (refresh) {
                        // refreshCallback();
                      }
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 110,
                      ),
                      child: Text(
                        'value',
                        style: TextStyle(
                          color: FrappePalette.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FrappeIcon(
              FrappeIcons.close_alt,
              size: 16,
            ),
          ),
          onTap: onDelete,
        ),
      ],
    );
  }
}
