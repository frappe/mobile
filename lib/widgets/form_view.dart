import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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
  Map updateObj = {};
  final _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  var docInfo;
  var docs;
  int bottomSelectedIndex = 0;

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

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(
          Icons.details,
        ),
        title: Text('Form'),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.message,
        ),
        title: Text('Timeline'),
      )
    ];
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureIssueDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // processData(widget.wireframe);
            docs = snapshot.data.values.docs;
            docInfo = snapshot.data.values.docInfo;

            return Scaffold(
                bottomNavigationBar: Container(
                  child: BottomNavigationBar(
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Colors.black38,
                    backgroundColor: Color.fromRGBO(237, 242, 247, 1),
                    currentIndex: bottomSelectedIndex,
                    items: buildBottomNavBarItems(),
                    onTap: (index) {
                      bottomTapped(index);
                    },
                  ),
                ),
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(200),
                  child: AppBar(
                    elevation: 0,
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(110),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                widget.appBarTitle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 28),
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
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ViewAttachments(
                                          docInfo["attachments"]);
                                    }));
                                  },
                                ),
                                Spacer(),
                                Column(
                                  children: <Widget>[
                                    CircleAvatar(child: Icon(Icons.person)),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    docInfo["assignments"].length != 0
                                        ? Text(
                                            docInfo["assignments"][0]["owner"])
                                        : Text('Unassigned')
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      IconButton(
                          disabledColor: Colors.black54,
                          color: Colors.black,
                          icon: Icon(
                            Icons.save,
                          ),
                          onPressed: formChanged
                              ? () async {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    var formValue = _fbKey.currentState.value;
                                    await updateDoc(
                                        widget.name, formValue, widget.doctype);
                                    _refresh();
                                  }
                                }
                              : null)
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EmailForm(
                          doctype: widget.doctype, doc: widget.name);
                    }));
                  },
                  child: Icon(Icons.email),
                ),
                body: Column(children: <Widget>[
                  Container(
                    color: Color.fromRGBO(237, 242, 247, 1),
                    height: 30,
                  ),
                  Expanded(
                    child: PageView(
                        onPageChanged: (index) {
                          pageChanged(index);
                        },
                        controller: _pageController,
                        children: <Widget>[
                          FormBuilder(
                            key: _fbKey,
                            child: Column(children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: GridView.count(
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
                            ]),
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
                  ),
                ]));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        });
  }
}
