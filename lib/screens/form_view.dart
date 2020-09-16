import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../config/palette.dart';

import '../utils/backend_service.dart';
import '../utils/frappe_alert.dart';
import '../utils/indicator.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';

import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';
import '../widgets/timeline.dart';
import '../widgets/user_avatar.dart';
import '../widgets/like_doc.dart';

import '../screens/no_internet.dart';
import '../screens/view_docinfo.dart';
import '../screens/email_form.dart';
import '../screens/comment_input.dart';

class FormView extends StatefulWidget {
  final String doctype;
  final String name;
  final Map meta;
  final bool queued;
  final Map queuedData;

  FormView({
    @required this.doctype,
    this.name,
    this.meta,
    this.queued = false,
    this.queuedData,
  });

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView>
    with SingleTickerProviderStateMixin {
  BackendService backendService;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool editMode = false;
  final user = localStorage.getString('user');

  @override
  void initState() {
    super.initState();
    backendService = BackendService();
  }

  void _refresh() {
    setState(() {
      editMode = false;
    });
  }

  Future _getData(ConnectivityStatus connectionStatus) {
    if (widget.queued) {
      return Future.delayed(
          Duration(seconds: 1), () => {"docs": widget.queuedData["data"]});
    } else {
      if (connectionStatus == ConnectivityStatus.offline) {
        return Future.delayed(
          Duration(seconds: 1),
          () {
            var response = getCache('${widget.doctype}${widget.name}');
            if (response != null) {
              return response["data"];
            } else {
              return {
                "success": false,
              };
            }
          },
        );
      } else {
        return backendService.getdoc(
          widget.doctype,
          widget.name,
        );
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

  Widget _bottomBar(Map doc) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CommentInput(
                        doctype: widget.doctype,
                        name: widget.name,
                        authorEmail: localStorage.getString('user'),
                        callback: _refresh,
                      );
                    },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EmailForm(
                        callback: _refresh,
                        subjectField: doc[widget.meta["subject_field"] ??
                            widget.meta["title_field"]],
                        senderField: doc[widget.meta["sender_field"]],
                        doctype: widget.doctype,
                        doc: widget.name,
                      );
                    },
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

  _handleUpdate(ConnectivityStatus connectionStatus) async {
    if (_fbKey.currentState.saveAndValidate()) {
      var formValue = _fbKey.currentState.value;
      if (connectionStatus == ConnectivityStatus.offline) {
        if (widget.queuedData != null) {
          widget.queuedData["data"] = [formValue];
          widget.queuedData["title"] = formValue[widget.meta["title_field"]];

          queue.putAt(
            widget.queuedData["qIdx"],
            widget.queuedData,
          );
        } else {
          queue.add({
            "type": "update",
            "name": widget.name,
            "doctype": widget.doctype,
            "title": formValue[widget.meta["title_field"]],
            "data": [formValue],
          });
        }
        FrappeAlert.infoAlert(
          title: 'No Internet Connection',
          subtitle: 'Added to Queue',
          context: context,
        );
      } else {
        await backendService.updateDoc(
          widget.doctype,
          widget.name,
          formValue,
        );
        FrappeAlert.infoAlert(
          title: 'Changes Saved',
          context: context,
        );
        _refresh();
      }
    }
  }

  Widget _appBar({
    Map doc,
    Map docInfo,
    BuildContext context,
    ConnectivityStatus connectionStatus,
  }) {
    var title = doc[widget.meta["title_field"]] ?? doc["name"];

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ViewDocInfo(
                            meta: widget.meta,
                            doc: doc,
                            docInfo: docInfo,
                            doctype: widget.doctype,
                            name: widget.name,
                            callback: _refresh,
                          );
                        },
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
                    Spacer(),
                    if (!widget.queued)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ViewDocInfo(
                                  doc: doc,
                                  meta: widget.meta,
                                  docInfo: docInfo,
                                  doctype: widget.doctype,
                                  name: widget.name,
                                  callback: _refresh,
                                );
                              },
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
                ? () => _handleUpdate(connectionStatus)
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
        future: _getData(connectionStatus),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data["success"] == false) {
              return NoInternet();
            }
            var docs = snapshot.data["docs"];
            var docInfo = snapshot.data["docinfo"];
            var builderContext;
            var likedBy = docs[0]['_liked_by'] != null
                ? json.decode(docs[0]['_liked_by'])
                : [];
            var isLikedByUser = likedBy.contains(user);

            return Scaffold(
              backgroundColor: Palette.bgColor,
              bottomNavigationBar: _bottomBar(docs[0]),
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
                                  fields: widget.meta["fields"],
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
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return Center(child: CircularProgressIndicator());
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
