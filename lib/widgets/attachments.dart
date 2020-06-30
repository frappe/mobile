import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/palette.dart';
import '../utils/http.dart';
import '../utils/helpers.dart';
import '../widgets/file_picker.dart';
import '../widgets/card_list_tile.dart';

class Attachments extends StatefulWidget {
  final String doctype;
  final String name;
  final Map docInfo;
  final Function callback;

  Attachments({
    @required this.doctype,
    @required this.name,
    this.docInfo,
    this.callback,
  });

  @override
  _AttachmentsState createState() => _AttachmentsState();
}

class _AttachmentsState extends State<Attachments> {
  Future _futureVal;

  @override
  void initState() {
    super.initState();
    _futureVal = Future.delayed(Duration(seconds: 0), () => widget.docInfo);
  }

  Future _getDocInfo() async {
    var data = {"doctype": widget.doctype, "name": widget.name};

    var response2 = await dio.post(
      '/method/frappe.desk.form.load.get_docinfo',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response2.statusCode == 200) {
      return response2.data["docinfo"];
    } else {
      throw Exception('Failed to load album');
    }
  }

  void _removeAttachment(String attachmentName) async {
    var data = {
      "fid": attachmentName,
      "dt": widget.doctype,
      "dn": widget.name,
    };

    var response2 = await dio.post(
      '/method/frappe.desk.form.utils.remove_attach',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response2.statusCode == 200) {
      showSnackBar('Attachment removed', context);
      _refresh();
      widget.callback();
      return;
    } else {
      throw Exception('Failed to load album');
    }
  }

  void _refresh() {
    setState(() {
      _futureVal = _getDocInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureVal,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docInfo = snapshot.data;
          return Container(
            padding: const EdgeInsets.all(8.0),
            color: Palette.bgColor,
            child: Column(
              children: <Widget>[
                docInfo["attachments"].isNotEmpty
                    ? Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children:
                              docInfo["attachments"].map<Widget>((attachment) {
                            var file = attachment["file_name"];
                            var ext = file.split('.').last;
                            var fileName = file.split('.').first;
                            return Container(
                              color: Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(ext.toUpperCase()),
                                ),
                                onTap: () {
                                  downloadFile(attachment["file_url"]);
                                },
                                title: Text(fileName),
                                trailing: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => _removeAttachment(
                                    attachment["name"],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : CardListTile(
                        title: Text(
                          'No Attachments',
                          style: Palette.altTextStyle,
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: CustomFilePicker(
                    doctype: widget.doctype,
                    name: widget.name,
                    callback: () {
                      _refresh();
                      widget.callback();
                    },
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
