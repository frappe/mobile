import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import '../datamodels/doctype_response.dart';
import '../config/palette.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../utils/cache_helper.dart';
import '../utils/helpers.dart';
import '../utils/config_helper.dart';
import '../utils/queue_helper.dart';
import '../utils/frappe_alert.dart';
import '../utils/indicator.dart';
import '../utils/enums.dart';

import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';
import '../widgets/timeline.dart';
import '../widgets/user_avatar.dart';
import '../widgets/like_doc.dart';

class FormView extends StatefulWidget {
  final String doctype;
  final String name;
  final bool queued;
  final Map queuedData;

  FormView({
    @required this.doctype,
    this.name,
    this.queued = false,
    this.queuedData,
  });

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool editMode = false;
  final user = ConfigHelper().user;

  void _refresh() {
    setState(() {
      editMode = false;
    });
  }

  Future _getData() async {
    if (widget.queued) {
      return Future.value(
        {
          "data": {
            "docs": widget.queuedData["data"],
          },
          "meta": await CacheHelper.getMeta(
            widget.doctype,
          )
        },
      );
    } else {
      var connectionStatus = Provider.of<ConnectivityStatus>(
        context,
      );

      var isOnline = await verifyOnline();

      if ((connectionStatus == null ||
              connectionStatus == ConnectivityStatus.offline) &&
          !isOnline) {
        var response = await CacheHelper.getCache(
          '${widget.doctype}${widget.name}',
        );
        response = response["data"];
        if (response != null) {
          return {
            "data": response,
            "meta": await CacheHelper.getMeta(
              widget.doctype,
            )
          };
        } else {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
          );
        }
      } else {
        return {
          "data": await locator<Api>().getdoc(
            widget.doctype,
            widget.name,
          ),
          "meta": await CacheHelper.getMeta(
            widget.doctype,
          )
        };
      }
    }
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

  Widget _bottomBar(Map doc, DoctypeResponse meta) {
    return Container(
      height: editMode ? 0 : 60,
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
                    doctype: widget.doctype,
                    name: widget.name,
                    authorEmail: ConfigHelper().user,
                    callback: _refresh,
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
                    callback: _refresh,
                    subjectField: doc[meta.docs[0].subjectField] ??
                        getTitle(meta.docs[0], doc),
                    senderField: doc[meta.docs[0].senderField],
                    doctype: widget.doctype,
                    doc: widget.name,
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

  _handleUpdate(Map doc, ConnectivityStatus connectionStatus,
      DoctypeResponse meta) async {
    if (_fbKey.currentState.saveAndValidate()) {
      var formValue = _fbKey.currentState.value;
      formValue.forEach((key, value) {
        if (value is Uint8List) {
          var str = base64.encode(value);

          formValue[key] = "data:image/png;base64,$str";
        }
      });
      var isOnline = await verifyOnline();
      if ((connectionStatus == null ||
              connectionStatus == ConnectivityStatus.offline) &&
          !isOnline) {
        if (widget.queuedData != null) {
          widget.queuedData["data"] = [
            {
              ...doc,
              ...formValue,
            }
          ];
          widget.queuedData["updated_keys"] = {
            ...widget.queuedData["updated_keys"],
            ...extractChangedValues(
              doc,
              formValue,
            )
          };
          widget.queuedData["title"] = getTitle(
            meta.docs[0],
            formValue,
          );

          QueueHelper.putAt(
            widget.queuedData["qIdx"],
            widget.queuedData,
          );
        } else {
          QueueHelper.add({
            "type": "Update",
            "name": widget.name,
            "doctype": widget.doctype,
            "title": getTitle(meta.docs[0], formValue),
            "updated_keys": extractChangedValues(doc, formValue),
            "data": [
              {
                ...doc,
                ...formValue,
              }
            ],
          });
        }
        FrappeAlert.infoAlert(
          title: 'No Internet Connection',
          subtitle: 'Added to Queue',
          context: context,
        );
        locator<NavigationService>().pop();
      } else {
        formValue = {
          ...doc,
          ...formValue,
        };

        try {
          var response = await locator<Api>().saveDocs(
            widget.doctype,
            formValue,
          );

          if (response.statusCode == HttpStatus.ok) {
            FrappeAlert.infoAlert(
              title: 'Changes Saved',
              context: context,
            );
            _refresh();
          }
        } catch (e) {
          showErrorDialog(e, context);
        }
      }
    }
  }

  Widget _appBar(
      {Map doc,
      Map docInfo,
      BuildContext context,
      ConnectivityStatus connectionStatus,
      @required DoctypeResponse meta}) {
    String title;
    if (widget.queuedData != null) {
      title = widget.queuedData["title"];
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
            onTap: !widget.queued
                ? () {
                    locator<NavigationService>().navigateTo(
                      Routes.viewDocInfo,
                      arguments: ViewDocInfoArguments(
                        meta: meta.docs[0],
                        doc: doc,
                        docInfo: docInfo,
                        doctype: widget.doctype,
                        name: widget.name,
                        callback: _refresh,
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
                    Indicator.buildStatusButton(widget.doctype, doc['status']),
                    VerticalDivider(),
                    if (widget.queued && widget.queuedData["error"] != null)
                      FrappeFlatButton.small(
                        height: 24,
                        title: "Show Error",
                        onPressed: () {
                          locator<NavigationService>().navigateTo(
                            Routes.queueError,
                            arguments: QueueErrorArguments(
                              error: widget.queuedData["error"],
                              dataToUpdate: widget.queuedData["updated_keys"],
                            ),
                          );
                        },
                        buttonType: ButtonType.secondary,
                      ),
                    Spacer(),
                    if (!widget.queued)
                      InkWell(
                        onTap: () {
                          locator<NavigationService>().navigateTo(
                            Routes.viewDocInfo,
                            arguments: ViewDocInfoArguments(
                              doc: doc,
                              meta: meta.docs[0],
                              docInfo: docInfo,
                              doctype: widget.doctype,
                              name: widget.name,
                              callback: _refresh,
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
        //     doctype: widget.doctype,
        //     name: widget.name,
        //     isFav: isLikedByUser,
        //   ),
        if (editMode)
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
                _refresh();
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 4,
          ),
          child: FrappeFlatButton(
            buttonType: ButtonType.primary,
            title: editMode ? 'Save' : 'Edit',
            onPressed: editMode
                ? () => _handleUpdate(doc, connectionStatus, meta)
                : () {
                    setState(() {
                      editMode = true;
                    });
                  },
          ),
        )
      ],
      expandedHeight: editMode ? 0.0 : 180.0,
      floating: true,
      pinned: true,
    );
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

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );
    return FutureBuilder(
        future: _getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            var docs = snapshot.data["data"]["docs"];
            var docInfo = snapshot.data["data"]["docinfo"];
            var meta = (snapshot.data["meta"] as DoctypeResponse);

            var builderContext;
            var likedBy = docs[0]['_liked_by'] != null
                ? json.decode(docs[0]['_liked_by'])
                : [];
            var isLikedByUser = likedBy.contains(user);

            return Scaffold(
              backgroundColor: Palette.bgColor,
              bottomNavigationBar: _bottomBar(docs[0], meta),
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
                                  editMode: editMode,
                                ),
                              ],
                            ),
                          ),
                          !widget.queued
                              ? Timeline([
                                  ...docInfo['comments'],
                                  ...docInfo["communications"],
                                  ...docInfo["versions"],
                                  // ...docInfo["views"],TODO
                                ], () {
                                  _refresh();
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
          } else {
            return Scaffold(
              body: snapshot.hasError
                  ? handleError(snapshot.error)
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            );
          }
        });
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
