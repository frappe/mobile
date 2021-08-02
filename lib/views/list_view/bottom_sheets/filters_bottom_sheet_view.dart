import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';

import 'package:frappe_app/views/list_view/bottom_sheets/edit_filter_bottom_sheet_view.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/frappe_button.dart';

import 'filters_bottom_sheet_viewmodel.dart';

class FiltersBottomSheetView extends StatelessWidget {
  final List<DoctypeField> fields;
  final List<Filter> filters;

  const FiltersBottomSheetView({
    required this.fields,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return BaseView<FiltersBottomSheetViewModel>(
      onModelReady: (model) {
        List<DoctypeField> prioritizedFilterFields = [
          DoctypeField(
            fieldname: '_assign',
            label: "Assigned To",
            options: 'User',
            fieldtype: "Link",
          ),
          DoctypeField(
            fieldname: 'owner',
            label: "Created By",
            options: 'User',
            fieldtype: "Link",
          ),
          ...fields.where((field) => field.inStandardFilter == 1).toList(),
          ...fields.where((field) => field.inStandardFilter == 0).toList(),
        ];

        model.fields = prioritizedFilterFields;
        if (filters.isEmpty) {
          model.addFilter();
        } else {
          model.filtersToApply = filters;
        }
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
                    onPressed: () {
                      Navigator.of(context).pop(
                        model.filtersToApply
                            .where(
                              (filterToApply) => filterToApply.value != null,
                            )
                            .toList(),
                      );
                    },
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
                'Clear All',
                style: TextStyle(
                  color: FrappePalette.red[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          body: ListView(
            children: [
              ...model.filtersToApply.asMap().entries.map(
                (entry) {
                  var filter = entry.value;
                  var idx = entry.key;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: AddFilter(
                      fields: model.fields,
                      filter: filter,
                      onDelete: () {
                        model.removeFilter(idx);
                      },
                      onUpdate: (Filter filter) {
                        model.updateFilter(
                          filter: filter,
                          index: idx,
                        );
                      },
                    ),
                  );
                },
              ).toList()
            ],
          ),
        ),
      ),
    );
  }
}

class AddFilter extends StatelessWidget {
  final List<DoctypeField> fields;
  final void Function() onDelete;
  final Function onUpdate;
  final Filter filter;

  const AddFilter({
    required this.fields,
    required this.onDelete,
    required this.onUpdate,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 36,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            6,
          ),
          color: FrappePalette.grey[100],
        ),
        padding: EdgeInsets.only(
          left: 5,
          right: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 72,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                child: Wrap(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Filter _filter = await showModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => EditFilterBottomSheetView(
                            page: 1,
                            fields: fields,
                            filter: filter,
                          ),
                        );

                        if (_filter != null && _filter.field != null) {
                          onUpdate(_filter);
                        }
                      },
                      child: Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 110,
                                  ),
                                  child: Text(
                                    filter.field.label!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: FrappePalette.grey[600],
                                    ),
                                  ),
                                ),
                                FrappeIcon(
                                  FrappeIcons.select,
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Filter _filter = await showModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => EditFilterBottomSheetView(
                            page: 2,
                            filter: filter,
                          ),
                        );

                        if (_filter != null && _filter.filterOperator != null) {
                          onUpdate(_filter);
                        }
                      },
                      child: Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filter.filterOperator.label,
                                  style: TextStyle(
                                    color: FrappePalette.grey[600],
                                  ),
                                ),
                                FrappeIcon(
                                  FrappeIcons.select,
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Filter _filter = await showModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => EditFilterBottomSheetView(
                            page: 3,
                            filter: filter,
                          ),
                        );

                        if (_filter != null && _filter.value != null) {
                          onUpdate(_filter);
                        }
                      },
                      child: Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 110,
                              ),
                              child: Text(
                                filter.value ?? "value",
                                style: TextStyle(
                                  color: FrappePalette.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                ),
                child: FrappeIcon(
                  FrappeIcons.close_alt,
                  size: 16,
                ),
              ),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
