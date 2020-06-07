import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/widgets/add_assignees.dart';
import 'package:frappe_app/widgets/comment_input.dart';
import 'package:frappe_app/widgets/like_doc.dart';
import 'package:rubber/rubber.dart';

import '../widgets/communication.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';
import '../utils/response_models.dart';
import '../widgets/email_form.dart';
import '../widgets/view_attachments.dart';

class FormView extends StatefulWidget {
  final String doctype;
  final String name;
  final Map wireframe;

  FormView({
    @required this.doctype,
    @required this.name,
    this.wireframe,
  });

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Future<DioGetDocResponse> futureIssueDetail;
  bool formChanged = false;
  bool editMode = false;
  final user = localStorage.getString('user');

  @override
  void initState() {
    futureIssueDetail = _fetchDoc(widget.doctype, widget.name);
    super.initState();
  }

  _updateDoc(String name, Map updateObj, String doctype) async {
    var response2 = await dio.put(
      '/resource/$doctype/$name',
      data: updateObj,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response2.statusCode == 200) {
      return;
    } else if (response2.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<DioGetDocResponse> _fetchDoc(String doctype, String name) async {
    var queryParams = {
      'doctype': doctype,
      'name': name,
    };

    final response2 = await dio.get(
      '/method/frappe.desk.form.load.getdoc',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response2.statusCode == 200) {
      return DioGetDocResponse.fromJson(response2.data);
    } else if (response2.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  void _refresh() {
    setState(() {
      futureIssueDetail = _fetchDoc(widget.doctype, widget.name);
      formChanged = false;
      editMode = false;
    });
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
          ),
        ),
      ];
    }

    for (int i = 0; i < l.length; i++) {
      if (i < size) {
        w.add(
          CircleAvatar(
            backgroundColor: Palette.bgColor,
            child: Text(l[i]["owner"][0].toUpperCase()),
          ),
        );
      } else {
        w.add(CircleAvatar(
          backgroundColor: Palette.bgColor,
          child: Text('+ ${l.length - size}'),
        ));
        break;
      }
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureIssueDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // processData(widget.wireframe);
            var docs = snapshot.data.values.docs;
            var docInfo = snapshot.data.values.docInfo;
            var builderContext;
            var likedBy = docs[0]['_liked_by'] != null
                ? json.decode(docs[0]['_liked_by'])
                : [];
            var isLikedByUser = likedBy.contains(user);

            return Scaffold(
                bottomNavigationBar: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Palette.lightGrey),
                  ),
                  child: BottomAppBar(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 70,
                            padding: EdgeInsets.all(8),
                            child: RaisedButton(
                              child: Text(
                                'Comment',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              color: Palette.offWhite,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CommentInput(
                                        doctype: widget.doctype,
                                        name: widget.name,
                                        authorEmail:
                                            localStorage.getString('user'),
                                        callback: _refresh,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 70,
                            padding: EdgeInsets.all(8),
                            child: RaisedButton(
                              child: Text(
                                'New Email',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              color: Palette.offWhite,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return EmailForm(
                                        callback: _refresh,
                                        subject: docs[0]["subject"],
                                        raisedBy: docs[0]["raised_by"],
                                        doctype: widget.doctype,
                                        doc: widget.name,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                            SliverAppBar(
                              flexibleSpace: FlexibleSpaceBar(
                                background: Container(
                                  padding: EdgeInsets.only(
                                    top: 90,
                                    right: 20,
                                    left: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                          docs[0][widget
                                              .wireframe["subject_field"]],
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
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Palette.lightGreen,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              docs[0]['status'].toUpperCase(),
                                              style: TextStyle(
                                                color: Palette.darkGreen,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return AddAssignees(
                                                        callback: _refresh,
                                                        assignments: docInfo[
                                                            "assignments"],
                                                        doctype: widget.doctype,
                                                        name: widget.name);
                                                  },
                                                ),
                                              );
                                            },
                                            child: Row(
                                              // children: _generateAssignees([1,2,3]),
                                              children: _generateAssignees(
                                                  docInfo["assignments"]),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                LikeDoc(
                                  doctype: widget.doctype,
                                  name: widget.name,
                                  isFav: isLikedByUser,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    iconSize: 18,
                                    icon:
                                        editMode ? Text('Save') : Text('Edit'),
                                    onPressed: editMode
                                        ? formChanged
                                            ? () async {
                                                if (_fbKey.currentState
                                                    .saveAndValidate()) {
                                                  var formValue =
                                                      _fbKey.currentState.value;
                                                  await _updateDoc(
                                                    widget.name,
                                                    formValue,
                                                    widget.doctype,
                                                  );
                                                  showSnackBar(
                                                    'Changes Saved',
                                                    builderContext,
                                                  );
                                                  _refresh();
                                                }
                                              }
                                            : () {
                                                showSnackBar(
                                                  'No Changes',
                                                  builderContext,
                                                );
                                                setState(() {
                                                  editMode = false;
                                                });
                                              }
                                        : () {
                                            setState(() {
                                              editMode = true;
                                            });
                                          },
                                  ),
                                )
                              ],
                              expandedHeight: 200.0,
                              floating: true,
                              pinned: true,
                            ),
                            SliverPersistentHeader(
                              delegate: _SliverAppBarDelegate(
                                TabBar(
                                  labelColor: Colors.black87,
                                  unselectedLabelColor: Colors.grey,
                                  tabs: [
                                    Tab(
                                      child: Text('FORM'),
                                    ),
                                    Tab(
                                      child: Text('TIMELINE'),
                                    ),
                                  ],
                                ),
                              ),
                              pinned: true,
                            ),
                          ];
                        },
                        body: TabBarView(children: [
                          Column(mainAxisSize: MainAxisSize.min, children: <
                              Widget>[
                            Container(
                              color: Color.fromRGBO(237, 242, 247, 1),
                              height: 40,
                            ),
                            FormBuilder(
                              readOnly: editMode ? false : true,
                              key: _fbKey,
                              child: Flexible(
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(10),
                                  child: ListView(
                                      padding: EdgeInsets.all(10),
                                      children: widget.wireframe["fields"]
                                          .where((field) {
                                        return field["hidden"] == false &&
                                            field["skip_field"] != true;
                                      }).map<Widget>((field) {
                                        var val = docs[0][field["fieldname"]];
                                        return Visibility(
                                          visible: editMode
                                              ? true
                                              : val != null && val != '',
                                          child: GridTile(
                                            child: generateChildWidget(
                                                field, val, (item) {
                                              setState(() {
                                                docs[0][field["fieldname"]] =
                                                    item;
                                                formChanged = true;
                                              });
                                            }),
                                          ),
                                        );
                                      }).toList()),
                                ),
                              ),
                            )
                          ]),
                          Communication(
                            docInfo: [
                              ...docInfo['comments'],
                              ...docInfo["communications"],
                              ...docInfo["versions"]
                            ],
                            callback: () {
                              _refresh();
                            },
                          ),
                        ]),
                      ),
                    );
                  },
                ));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
