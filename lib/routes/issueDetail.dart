import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:support_app/routes/issueCommunication.dart';
import 'package:support_app/utils/helpers.dart';
import 'package:support_app/widgets/customFieldDropdown.dart';
import 'package:support_app/widgets/issueTypeDropdown.dart';
import 'package:support_app/widgets/priorityDropdown.dart';
import 'package:support_app/widgets/userDropdown.dart';
import '../widgets/issueStatusDropdown.dart';
import '../utils/http.dart';

class IssueDetailModel {
  final List docs;
  final Map docInfo;

  IssueDetailModel({
    this.docs,
    this.docInfo,
  });

  factory IssueDetailModel.fromJson(json) {
    return IssueDetailModel(
      docs: json['docs'],
      docInfo: json['docinfo'],
    );
  }
}

class IssueDetailResponse {
  final values;
  final String error;

  IssueDetailResponse(this.values, this.error);

  IssueDetailResponse.fromJson(json)
      : values = IssueDetailModel.fromJson(json),
        error = "";

  IssueDetailResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

sendEmail(
    {@required recipients,
    cc,
    bcc,
    @required subject,
    @required content,
    @required doctype,
    @required doctypeName,
    sendEmail,
    printHtml,
    sendMeACopy,
    printFormat,
    emailTemplate,
    attachments,
    readReceipt,
    printLetterhead}) async {
  var queryParams = {
    'recipients': recipients,
    'subject': subject,
    'content': content,
    'doctype': doctype,
    'name': doctypeName
  };

  final response2 = await dio.post(
      '/method/frappe.core.doctype.communication.email.make',
      data: queryParams,
      options: Options(contentType: Headers.formUrlEncodedContentType));
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // return DioResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

postComment(refDocType, refName, content, email) async {
  var queryParams = {
    'reference_doctype': refDocType,
    'reference_name': refName,
    'content': content,
    'comment_email': email,
  };

  final response2 = await dio.post('/method/frappe.desk.form.utils.add_comment',
      data: queryParams,
      options: Options(contentType: Headers.formUrlEncodedContentType));
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // return DioResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

fetchIssueDetail(String name) async {
  var queryParams = {
    'doctype': 'Issue',
    'name': name,
  };

  final response2 = await dio.get('/method/frappe.desk.form.load.getdoc',
      queryParameters: queryParams);

  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return IssueDetailResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

updateIssue(String name, var updateObj) async {
  var response2 = await dio.put('/resource/Issue/${name}', data: updateObj);

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

class IssueDetail extends StatefulWidget {
  final String name;

  const IssueDetail(this.name);

  @override
  _IssueDetailState createState() => _IssueDetailState();
}

class _IssueDetailState extends State<IssueDetail> {
  bool formChanged = false;
  var futureIssueDetail;
  var docInfo;

  String statusDropdownVal;
  String priorityDropdownVal;
  String issueTypeDropdownVal;
  String userDropdownVal;
  String moduleDropdownVal;
  String supportLevelDropdownVal;
  String frappeSupportTeamDropdownVal;

  final commentController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureIssueDetail = fetchIssueDetail(widget.name);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    commentController.dispose();
    emailController.dispose();
    super.dispose();
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
                    return IssueCommunication(communcation);
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
                  var updateObj = {};
                  if (statusDropdownVal != null) {
                    updateObj['status'] = statusDropdownVal;
                  }

                  if (priorityDropdownVal != null) {
                    updateObj['priority'] = priorityDropdownVal;
                  }

                  if (issueTypeDropdownVal != null) {
                    updateObj['issue_type'] = issueTypeDropdownVal;
                  }

                  if (userDropdownVal != null) {
                    updateObj['resolved_by'] = userDropdownVal;
                  }

                  if (moduleDropdownVal != null) {
                    updateObj['module'] = moduleDropdownVal;
                  }

                  if (supportLevelDropdownVal != null) {
                    updateObj['support_team'] = supportLevelDropdownVal;
                  }

                  if (frappeSupportTeamDropdownVal != null) {
                    updateObj['frappe_support_team'] =
                        frappeSupportTeamDropdownVal;
                  }

                  updateIssue(widget.name, updateObj);
                  setState(() {
                    formChanged = false;
                  });
                }
              : null,
        ),
        appBar: AppBar(
          title: Text('Issue Detail'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                logout(context);
              },
            )
          ],
        ),
        body: FutureBuilder(
            future: futureIssueDetail,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var doc = snapshot.data.values.docs[0];
                docInfo = snapshot.data.values.docInfo;

                statusDropdownVal = statusDropdownVal != null
                    ? statusDropdownVal
                    : doc["status"];
                priorityDropdownVal = priorityDropdownVal != null
                    ? priorityDropdownVal
                    : doc["priority"];
                issueTypeDropdownVal = issueTypeDropdownVal != null
                    ? issueTypeDropdownVal
                    : doc["issue_type"];
                userDropdownVal = userDropdownVal != null
                    ? userDropdownVal
                    : doc["resolved_by"];
                moduleDropdownVal = moduleDropdownVal != null
                    ? moduleDropdownVal
                    : doc["module"];
                supportLevelDropdownVal = supportLevelDropdownVal != null
                    ? supportLevelDropdownVal
                    : doc["support_team"];
                frappeSupportTeamDropdownVal =
                    frappeSupportTeamDropdownVal != null
                        ? frappeSupportTeamDropdownVal
                        : doc["frappe_support_team"];

                return Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Text(
                        doc["subject"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    Expanded(
                      child: GridView.count(
                        padding: EdgeInsets.all(10),
                        childAspectRatio: 2.0,
                        crossAxisCount: 2,
                        children: <Widget>[
                          GridTile(
                            header: Text('Issue Status'),
                            child: IssueStatusDropdown(
                              value: statusDropdownVal,
                              onChanged: (val) {
                                setState(() {
                                  statusDropdownVal = val;
                                  formChanged = true;
                                });
                              },
                            ),
                          ),
                          GridTile(
                            header: Text('Issue Priority'),
                            child: PriorityDropdown(
                              value: priorityDropdownVal,
                              onChanged: (val) {
                                setState(() {
                                  priorityDropdownVal = val;
                                  formChanged = true;
                                });
                              },
                            ),
                          ),
                          GridTile(
                            header: Text('Issue Type'),
                            child: IssueTypeDropdown(
                              value: issueTypeDropdownVal,
                              onChanged: (val) {
                                setState(() {
                                  issueTypeDropdownVal = val;
                                  formChanged = true;
                                });
                              },
                            ),
                          ),
                          GridTile(
                            header: Text('Resolved By'),
                            child: UserDropdown(
                              value: userDropdownVal,
                              onChanged: (val) {
                                setState(() {
                                  userDropdownVal = val;
                                  formChanged = true;
                                });
                              },
                            ),
                          ),
                          GridTile(
                            header: Text('Issue Found In'),
                            child: CustomFieldDropdown(
                              fieldName: 'module',
                              doctype: 'Issue',
                              hint: 'Issues Found In',
                              value: moduleDropdownVal,
                              onChanged: (val) {
                                setState(() {
                                  moduleDropdownVal = val;
                                  formChanged = true;
                                });
                              },
                            ),
                          ),
                          GridTile(
                            header: Text('Support Level'),
                            child: CustomFieldDropdown(
                              fieldName: 'support_team',
                              doctype: 'Issue',
                              hint: 'Support Level',
                              value: supportLevelDropdownVal,
                              onChanged: (val) {
                                setState(() {
                                  supportLevelDropdownVal = val;
                                  formChanged = true;
                                });
                              },
                            ),
                          ),
                          GridTile(
                            header: Text('Frappe Support Team'),
                            child: CustomFieldDropdown(
                              fieldName: 'frappe_support_team',
                              doctype: 'Issue',
                              hint: 'Frappe Support Team',
                              value: frappeSupportTeamDropdownVal,
                              onChanged: (val) {
                                setState(() {
                                  frappeSupportTeamDropdownVal = val;
                                  formChanged = true;
                                });
                              },
                            ),
                          ),
                          // Row(
                          //   children: <Widget>[
                          //     Flexible(
                          //       child: TextField(
                          //         controller: emailController,
                          //         decoration:
                          //             const InputDecoration(hintText: "Email"),
                          //       ),
                          //     ),
                          //     RaisedButton(
                          //       onPressed: () {
                          //         sendEmail(
                          //             content: emailController.text,
                          //             doctype: 'Issue',
                          //             doctypeName: widget.name,
                          //             recipients: 'sumit@iwebnotes.com',
                          //             subject: 'test subject');
                          //       },
                          //       child: Text('Send'),
                          //     )
                          //   ],
                          // ),
                          // Row(
                          //   children: <Widget>[
                          //     Flexible(
                          //       child: TextField(
                          //         controller: commentController,
                          //         decoration: const InputDecoration(
                          //             hintText: "Comment"),
                          //       ),
                          //     ),
                          //     RaisedButton(
                          //       onPressed: () {
                          //         postComment('Issue', doc["name"],
                          //             commentController.text, 'Administrator');
                          //       },
                          //       child: Text('Post'),
                          //     )
                          //   ],
                          // ),
                        ],
                      ),
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            }));
  }
}
