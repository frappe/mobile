import 'package:flutter/material.dart';
import 'package:support_app/widgets/communication.dart';
import 'package:support_app/utils/helpers.dart';
import 'package:support_app/utils/http.dart';
import 'package:support_app/utils/response_models.dart';

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
  final String app_bar_title;

  FormView({@required this.doctype, @required this.name, this.wireframe, @required this.app_bar_title});

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  Future<DioGetDocResponse> futureIssueDetail;
  bool formChanged = false;
  Map updateObj = {};
  var docInfo;

  @override
  void initState() {
    super.initState();
    futureIssueDetail = fetchDoc(widget.doctype, widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 55.0,
        child: BottomAppBar(
          color: Color.fromRGBO(58, 66, 86, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.message, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    var communcation = {
                      "communications": docInfo["communications"],
                      "comments": docInfo["comments"]
                    };
                    return Communication(communication: communcation, refDoctype: widget.doctype, refName: widget.name,);
                  }));
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.save,
          color: Colors.white,
        ),
        onPressed: formChanged
            ? () {
                updateDoc(widget.name, updateObj, widget.doctype);
                setState(() {
                  formChanged = false;
                });
              }
            : null,
      ),
      appBar: AppBar(
        title: Text(widget.app_bar_title),
      ),
      body: FutureBuilder(
        future: futureIssueDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // processData(widget.wireframe);
            var docs = snapshot.data.values.docs;
            docInfo = snapshot.data.values.docInfo;

            return Column(children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  docs[0]["subject"],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Expanded(
                  child: GridView.count(
                      padding: EdgeInsets.all(10),
                      childAspectRatio: 2.0,
                      crossAxisCount: 2,
                      children: widget.wireframe["fields"].where((field) {
                        return field["hidden"] == false && field["skip_field"] != true;
                      }).map<Widget>((field) {
                        var val = docs[0][field["fieldname"]];
                        return GridTile(
                          // header: Text(grid["header"]),
                          child: generateChildWidget(field, val, (item) {
                            updateObj[field["fieldname"]] = item;
                            setState(() {
                              docs[0][field["fieldname"]] = item;
                              formChanged = true;
                            });
                          }),
                        );
                      }).toList()))
            ]);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
