import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/form_view/form_view_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../model/doctype_response.dart';
import '../../config/palette.dart';

import '../../app/locator.dart';
import '../../app/router.gr.dart';

import '../../services/navigation_service.dart';

import '../../utils/helpers.dart';
import '../../utils/frappe_alert.dart';
import '../../utils/indicator.dart';
import '../../utils/enums.dart';

import '../../model/config.dart';

import '../../widgets/custom_form.dart';
import '../../widgets/frappe_button.dart';
import '../../widgets/timeline.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/like_doc.dart';

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
        model.getData(
          connectivityStatus: connectionStatus,
          queued: queued,
          queuedData: queuedData,
          doctype: meta.docs[0].name,
          name: name,
        );
      },
      onModelClose: (model) {
        model.editMode = false;
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
                  return handleError(model.error);
                }
                var docs = model.formData["docs"];
                var docInfo = model.formData["docinfo"];

                var builderContext;
                var likedBy = docs[0]['_liked_by'] != null
                    ? json.decode(docs[0]['_liked_by'])
                    : [];
                var isLikedByUser = likedBy.contains(model.user);

                return Scaffold(
                  backgroundColor: Palette.bgColor,
                  bottomNavigationBar: _bottomBar(
                    doc: docs[0],
                    meta: meta,
                    model: model,
                  ),
                  body: Builder(
                    builder: (context) {
                      builderContext = context;
                      return DefaultTabController(
                        length: 2,
                        child: NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              _appBar(
                                context: builderContext,
                                connectionStatus: connectionStatus,
                                doc: docs[0],
                                docInfo: docInfo,
                                meta: meta,
                                model: model,
                              ),
                              _tabHeader(),
                            ];
                          },
                          body: TabBarView(
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      color: Palette.bgColor,
                                      height: 10,
                                    ),
                                    CustomForm(
                                      fields: meta.docs[0].fields,
                                      formKey: _fbKey,
                                      doc: docs[0],
                                      viewType: ViewType.form,
                                      editMode: model.editMode,
                                    ),
                                  ],
                                ),
                              ),
                              !queued
                                  ? Timeline([
                                      ...docInfo['comments'],
                                      ...docInfo["communications"],
                                      ...docInfo["versions"],
                                      // ...docInfo["views"],TODO
                                    ], () {
                                      model.refresh();
                                    })
                                  : Center(
                                      child: Text(
                                        'Activity not available in offline mode',
                                      ),
                                    ),
                            ],
                          ),
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

  Widget _tabHeader() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              child: Text('Detail'),
            ),
            Tab(
              child: Text('Activity'),
            ),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _appBar(
      {Map doc,
      Map docInfo,
      BuildContext context,
      ConnectivityStatus connectionStatus,
      @required FormViewViewModel model,
      @required DoctypeResponse meta}) {
    String title;
    if (queuedData != null) {
      title = queuedData["title"];
    } else {
      title = getTitle(meta.docs[0], doc) ?? "";
    }

    return SliverAppBar(
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: EdgeInsets.only(
            top: 90,
            right: 20,
            left: 20,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: !queued
                ? () {
                    locator<NavigationService>().navigateTo(
                      Routes.viewDocInfo,
                      arguments: ViewDocInfoArguments(
                        meta: meta.docs[0],
                        doc: doc,
                        docInfo: docInfo,
                        doctype: meta.docs[0].name,
                        name: name,
                        callback: model.refresh,
                      ),
                    );
                  }
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: <Widget>[
                    Indicator.buildStatusButton(
                        meta.docs[0].name, doc['status']),
                    VerticalDivider(),
                    if (queued && queuedData["error"] != null)
                      FrappeFlatButton.small(
                        height: 24,
                        title: "Show Error",
                        onPressed: () {
                          locator<NavigationService>().navigateTo(
                            Routes.queueError,
                            arguments: QueueErrorArguments(
                              error: queuedData["error"],
                              dataToUpdate: queuedData["updated_keys"],
                            ),
                          );
                        },
                        buttonType: ButtonType.secondary,
                      ),
                    Spacer(),
                    if (!queued)
                      InkWell(
                        onTap: () {
                          locator<NavigationService>().navigateTo(
                            Routes.viewDocInfo,
                            arguments: ViewDocInfoArguments(
                              doc: doc,
                              meta: meta.docs[0],
                              docInfo: docInfo,
                              doctype: meta.docs[0].name,
                              name: name,
                              callback: model.refresh,
                            ),
                          );
                        },
                        child: Row(
                          children: _generateAssignees(docInfo["assignments"]),
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        // if (!editMode)
        //   LikeDoc(
        //     doctype: doctype,
        //     name: name,
        //     isFav: isLikedByUser,
        //   ),
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
                model.refresh();
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
                      doc: doc,
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
      expandedHeight: model.editMode ? 0.0 : 180.0,
      floating: true,
      pinned: true,
    );
  }

  List<Widget> _generateAssignees(List l) {
    const int size = 2;
    List<Widget> w = [];

    if (l.length == 0) {
      return [
        CircleAvatar(
          backgroundColor: Palette.bgColor,
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ];
    }

    for (int i = 0; i < l.length; i++) {
      if (i < size) {
        w.add(
          UserAvatar(uid: l[i]["owner"]),
        );
      } else {
        w.add(UserAvatar.renderShape(txt: "+ ${l.length - size}"));
        break;
      }
    }
    return w;
  }

  Widget _bottomBar({
    @required Map doc,
    @required DoctypeResponse meta,
    @required FormViewViewModel model,
  }) {
    return Container(
      height: model.editMode ? 0 : 60,
      child: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Spacer(),
            FrappeRaisedButton(
              minWidth: 120,
              title: 'Comment',
              onPressed: () {
                locator<NavigationService>().navigateTo(
                  Routes.commentInput,
                  arguments: CommentInputArguments(
                    doctype: meta.docs[0].name,
                    name: name,
                    authorEmail: Config().user,
                    callback: model.refresh,
                  ),
                );
              },
            ),
            SizedBox(
              width: 10,
            ),
            FrappeRaisedButton(
              minWidth: 120,
              title: 'New Email',
              onPressed: () {
                locator<NavigationService>().navigateTo(
                  Routes.emailForm,
                  arguments: EmailFormArguments(
                    callback: model.refresh,
                    subjectField: doc[meta.docs[0].subjectField] ??
                        getTitle(meta.docs[0], doc),
                    senderField: doc[meta.docs[0].senderField],
                    doctype: meta.docs[0].name,
                    doc: name,
                  ),
                );
              },
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
