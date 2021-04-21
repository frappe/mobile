// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/comment_input.dart';
import 'package:frappe_app/views/form_view/form_view_viewmodel.dart';
import 'package:frappe_app/widgets/collapsed_avatars.dart';
import 'package:frappe_app/widgets/custom_expansion_tile.dart';
import 'package:frappe_app/widgets/timeline.dart';
import 'package:provider/provider.dart';

import 'package:frappe_app/views/form_view/bottom_sheets/assignees/assignees_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/reviews/view_reviews_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/share/share_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/tags/tags_bottom_sheet_view.dart';
import 'package:frappe_app/widgets/collapsed_reviews.dart';

import '../../model/doctype_response.dart';
import '../../config/palette.dart';

import '../../utils/helpers.dart';
import '../../utils/frappe_alert.dart';
import '../../utils/enums.dart';

import '../../widgets/custom_form.dart';
import '../../widgets/frappe_button.dart';

class FormView extends StatelessWidget {
  final String name;
  final bool queued;
  final Map queuedData;
  final DoctypeResponse meta;

  FormView({
    @required this.meta,
    this.name,
    this.queued = false,
    this.queuedData,
  });

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );
    return BaseView<FormViewViewModel>(
      onModelReady: (model) {
        model.communicationOnly = true;
        model.editMode = false;
        model.getData(
          connectivityStatus: connectionStatus,
          queued: queued,
          queuedData: queuedData,
          doctype: meta.docs[0].name,
          name: name,
        );
      },
      onModelClose: (model) {
        model.error = null;
      },
      builder: (context, model, child) => model.state == ViewState.busy
          ? Scaffold(
              body: Center(
              child: CircularProgressIndicator(),
            ))
          : Builder(
              builder: (context) {
                if (model.error != null) {
                  return handleError(
                    error: model.error,
                    context: context,
                  );
                }
                var docs = model.formData.docs;

                var builderContext;

                // var likedBy = docs[0]['_liked_by'] != null
                //     ? json.decode(docs[0]['_liked_by'])
                //     : [];
                // var isLikedByUser = likedBy.contains(model.user);

                return Scaffold(
                  backgroundColor: Palette.bgColor,
                  appBar: AppBar(
                    elevation: 0.8,
                    backgroundColor: Colors.white,
                    title: Text('${meta.docs[0].name} Details'),
                    actions: [
                      if (model.editMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 4,
                          ),
                          child: FrappeFlatButton(
                            buttonType: ButtonType.secondary,
                            title: 'Cancel',
                            onPressed: () {
                              _fbKey.currentState.reset();
                              model.toggleEdit();
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8,
                        ),
                        child: FrappeFlatButton(
                          buttonType: ButtonType.primary,
                          title: model.editMode ? 'Save' : 'Edit',
                          onPressed: model.editMode
                              ? () => _handleUpdate(
                                    doc: docs[0],
                                    connectionStatus: connectionStatus,
                                    meta: meta,
                                    model: model,
                                    context: context,
                                  )
                              : () {
                                  model.toggleEdit();
                                },
                        ),
                      )
                    ],
                  ),
                  body: Builder(
                    builder: (context) {
                      builderContext = context;
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: FrappePalette.grey[50],
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Text(
                                getTitle(meta.docs[0], docs[0]) ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FrappePalette.grey[900],
                                ),
                              ),
                            ),
                            DocInfo(
                              name: name,
                              doctype: meta.docs[0].name,
                              docInfo: model.docinfo,
                              refreshCallback: () {
                                model.getData(
                                  connectivityStatus: connectionStatus,
                                  queued: queued,
                                  queuedData: queuedData,
                                  doctype: meta.docs[0].name,
                                  name: name,
                                );
                              },
                            ),
                            CustomForm(
                              fields: meta.docs[0].fields,
                              formKey: _fbKey,
                              doc: docs[0],
                              viewType: ViewType.form,
                              editMode: model.editMode,
                            ),
                            ListTileTheme(
                              tileColor: Colors.white,
                              child: CustomExpansionTile(
                                maintainState: true,
                                initiallyExpanded: false,
                                title: Text(
                                  "Add a comment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                children: [
                                  CommentInput(
                                    name: name,
                                    doctype: meta.docs[0].name,
                                    callback: () {
                                      model.updateDocinfo(
                                        doctype: meta.docs[0].name,
                                        name: name,
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                            Timeline(
                              docinfo: model.docinfo,
                              doctype: meta.docs[0].name,
                              name: name,
                              communicationOnly: model.communicationOnly,
                              switchCallback: (val) {
                                model.toggleSwitch(val);
                              },
                              refreshCallback: () {
                                model.updateDocinfo(
                                  doctype: meta.docs[0].name,
                                  name: name,
                                );
                              },
                              emailSubjectField:
                                  docs[0][meta.docs[0].subjectField] ??
                                      getTitle(
                                        meta.docs[0],
                                        docs[0],
                                      ),
                              emailSenderField: docs[0]
                                  [meta.docs[0].senderField],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  _handleUpdate({
    @required Map doc,
    @required ConnectivityStatus connectionStatus,
    @required DoctypeResponse meta,
    @required FormViewViewModel model,
    @required BuildContext context,
  }) async {
    if (_fbKey.currentState.saveAndValidate()) {
      var formValue = _fbKey.currentState.value;

      try {
        await model.handleUpdate(
          connectivityStatus: connectionStatus,
          name: name,
          doctype: meta.docs[0].name,
          meta: meta,
          formValue: formValue,
          doc: doc,
          queuedData: queuedData,
        );
        FrappeAlert.infoAlert(
          title: 'Changes Saved',
          context: context,
        );
      } catch (e) {
        showErrorDialog(e, context);
      }
    }
  }
}

class DocInfo extends StatelessWidget {
  final Docinfo docInfo;
  final String doctype;
  final String name;
  final Function refreshCallback;

  const DocInfo({
    @required this.docInfo,
    @required this.refreshCallback,
    @required this.doctype,
    @required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        var reviews = docInfo.energyPointLogs.where((item) {
          return ["Appreciation", "Criticism"].contains(item.type);
        }).toList();
        List tags = docInfo.tags.isNotEmpty ? docInfo.tags.split(',') : [];
        return Container(
          color: FrappePalette.grey[50],
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DocInfoItem(
                title: 'Assignees',
                actionTitle: 'Add assignee',
                actionIcon: FrappeIcons.add_user,
                filledWidget: docInfo.assignments.isNotEmpty
                    ? CollapsedAvatars(
                        docInfo.assignments.map(
                          (assignment) {
                            return assignment.owner;
                          },
                        ).toList(),
                      )
                    : null,
                onTap: () async {
                  bool refresh = await showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (context) => AssigneesBottomSheetView(
                          assignees: docInfo.assignments,
                          doctype: doctype,
                          name: name,
                        ),
                      ) ??
                      false;

                  if (refresh) {
                    refreshCallback();
                  }
                },
              ),
              DocInfoItem(
                title: 'Attachments',
                actionTitle: 'Attach file',
                filledWidget: docInfo.attachments.isNotEmpty
                    ? Text(
                        '${docInfo.attachments.length} Attachments',
                        style: TextStyle(
                          fontSize: 13,
                          color: FrappePalette.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : null,
                actionIcon: FrappeIcons.attachment,
                onTap: () async {
                  bool refresh = await showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (context) => ViewAttachmentsBottomSheetView(
                          attachments: docInfo.attachments,
                          name: name,
                          doctype: doctype,
                        ),
                      ) ??
                      false;

                  if (refresh) {
                    refreshCallback();
                  }
                },
              ),
              if (docInfo.energyPointLogs != null)
                DocInfoItem(
                  title: 'Reviews',
                  actionTitle: 'Add review',
                  filledWidget: reviews.isNotEmpty
                      ? CollapsedReviews(
                          reviews,
                        )
                      : null,
                  actionIcon: FrappeIcons.review,
                  onTap: () async {
                    bool refresh = await showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          builder: (context) => ViewReviewsBottomSheetView(
                            reviews: reviews,
                          ),
                        ) ??
                        false;

                    if (refresh) {
                      refreshCallback();
                    }
                  },
                ),
              DocInfoItem(
                title: 'Tags',
                actionTitle: 'Add tags',
                actionIcon: FrappeIcons.tag,
                filledWidget: tags.isNotEmpty
                    ? Text(
                        '${tags.length} Tags',
                        style: TextStyle(
                          fontSize: 13,
                          color: FrappePalette.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : null,
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    builder: (context) => TagsBottomSheetView(
                      tags: tags,
                      doctype: doctype,
                      name: name,
                      refreshCallback: refreshCallback,
                    ),
                  );
                },
              ),
              DocInfoItem(
                title: 'Shared',
                actionTitle: 'Shared with',
                filledWidget: docInfo.shared.isNotEmpty
                    ? CollapsedAvatars(
                        docInfo.shared.map(
                          (share) {
                            return share.owner;
                          },
                        ).toList(),
                      )
                    : null,
                showBorder: false,
                actionIcon: FrappeIcons.share,
                onTap: () async {
                  bool refresh = await showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (context) => ShareBottomSheetView(
                          shares: docInfo.shared,
                          doctype: doctype,
                          name: name,
                        ),
                      ) ??
                      false;

                  if (refresh) {
                    refreshCallback();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class DocInfoItem extends StatelessWidget {
  final String title;
  final String actionTitle;
  final String actionIcon;
  final Function onTap;
  final bool showBorder;
  final Widget filledWidget;

  const DocInfoItem({
    Key key,
    @required this.title,
    @required this.actionTitle,
    @required this.actionIcon,
    @required this.onTap,
    this.filledWidget,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: FlatButton(
        onPressed: onTap,
        shape: showBorder
            ? Border(
                bottom: BorderSide(
                  color: FrappePalette.grey[200],
                  width: 2,
                ),
              )
            : null,
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: FrappePalette.grey[900],
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
            filledWidget ??
                Row(
                  children: [
                    FrappeIcon(
                      actionIcon,
                      color: FrappePalette.grey[600],
                      size: 13,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      actionTitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: FrappePalette.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
