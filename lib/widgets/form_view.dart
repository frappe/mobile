import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/widgets/add_assignees.dart';
import 'package:frappe_app/widgets/comment_input.dart';

import '../widgets/communication.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';
import '../utils/response_models.dart';
import '../widgets/email_form.dart';
import '../widgets/view_attachments.dart';

Future<DioGetDocResponse> fetchDoc(String doctype, String name) async {
  var queryParams = {
    'doctype': doctype,
    'name': name,
  };

  final response2 = await dio.get('/method/frappe.desk.form.load.getdoc',
      queryParameters: queryParams);

  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioGetDocResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

updateDoc(String name, Map updateObj, String doctype) async {
  var response2 = await dio.put('/resource/$doctype/$name', data: updateObj);

  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // return IssueDetailResponse.fromJson(response2.data);
    return;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class FormView extends StatefulWidget {
  final String doctype;
  final String name;
  final Map wireframe;
  final String appBarTitle;

  FormView(
      {@required this.doctype,
      @required this.name,
      this.wireframe,
      @required this.appBarTitle});

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Future<DioGetDocResponse> futureIssueDetail;
  bool formChanged = false;

  @override
  void initState() {
    super.initState();
    futureIssueDetail = fetchDoc(widget.doctype, widget.name);
  }

  void _refresh() {
    setState(() {
      futureIssueDetail = fetchDoc(widget.doctype, widget.name);
      formChanged = false;
    });
  }

  List<Widget> _generateAssignees(List l) {
    const int size = 2;
    List<Widget> w = [];

    if (l.length == 0) {
      return [CircleAvatar(child: Icon(Icons.add))];
    }

    for (int i = 0; i < l.length; i++) {
      if (i < size) {
        w.add(
          CircleAvatar(
            child: Text(l[i]["owner"][0].toUpperCase()),
          ),
        );
      } else {
        w.add(CircleAvatar(
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
                        RaisedButton(
                          child: Text('Reply'),
                          color: Palette.offWhite,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return EmailForm(
                                      doctype: widget.doctype,
                                      doc: widget.name);
                                },
                              ),
                            );
                          },
                        ),
                        VerticalDivider(),
                        RaisedButton(
                          child: Text('Comment'),
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
                      ],
                    ),
                  ),
                ),
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(200),
                  child: AppBar(
                    elevation: 4,
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(110),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                widget.appBarTitle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.lens,
                                  size: 10,
                                  color: setStatusColor(docs[0]['status']),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(docs[0]['status'].toUpperCase()),
                                SizedBox(
                                  width: 16,
                                ),
                                IconButton(
                                  icon: Icon(Icons.attach_file),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ViewAttachments(
                                              docInfo["attachments"]);
                                        },
                                      ),
                                    );
                                  },
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddAssignees(
                                              assignments:
                                                  docInfo["assignments"],
                                              doctype: widget.doctype,
                                              name: widget.name);
                                        },
                                      ),
                                    ).then((val) {
                                      _refresh();
                                    });
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          disabledColor: Colors.black54,
                          color: Colors.black,
                          icon: Text('Save'),
                          onPressed: formChanged
                              ? () async {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    var formValue = _fbKey.currentState.value;
                                    await updateDoc(
                                        widget.name, formValue, widget.doctype);
                                        showSnackBar('Changes Saved', builderContext);
                                    _refresh();
                                  }
                                }
                              : () => showSnackBar('No Changes', builderContext)
                        ),
                      )
                    ],
                  ),
                ),
                // floatingActionButton: FloatingActionButton(
                //   onPressed: () {
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) {
                //       return EmailForm(
                //           doctype: widget.doctype, doc: widget.name);
                //     }));
                //   },
                //   child: Icon(Icons.email),
                // ),
                body: Builder(
                  builder: (context) {
                    builderContext = context;
                    return SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              color: Color.fromRGBO(237, 242, 247, 1),
                              height: 40,
                            ),
                            FormBuilder(
                              key: _fbKey,
                              child: Flexible(
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(10),
                                  child: GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          ScrollPhysics(), // to disable GridView's scrolling
                                      padding: EdgeInsets.all(10),
                                      childAspectRatio: 2.0,
                                      crossAxisSpacing: 10.0,
                                      crossAxisCount: 2,
                                      children: widget.wireframe["fields"]
                                          .where((field) {
                                        return field["hidden"] == false &&
                                            field["skip_field"] != true;
                                      }).map<Widget>((field) {
                                        var val = docs[0][field["fieldname"]];
                                        return GridTile(
                                          child: generateChildWidget(field, val,
                                              (item) {
                                            setState(() {
                                              docs[0][field["fieldname"]] =
                                                  item;
                                              formChanged = true;
                                            });
                                          }),
                                        );
                                      }).toList()),
                                ),
                              ),
                            ),
                            Container(
                              color: Color.fromRGBO(237, 242, 247, 1),
                              height: 30,
                            ),
                            Communication(
                              docInfo: docInfo,
                              doctype: widget.doctype,
                              name: widget.name,
                              callback: () {
                                _refresh();
                              },
                            ),
                          ]),
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
