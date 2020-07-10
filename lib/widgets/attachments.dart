import 'package:flutter/material.dart';
import 'package:frappe_app/utils/backend_service.dart';

import '../config/palette.dart';
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
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);

    _futureVal = Future.delayed(Duration(seconds: 0), () => widget.docInfo);
  }

  void _refresh() {
    setState(() {
      _futureVal = backendService.getDocinfo(widget.doctype, widget.name);
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
                                  onPressed: () async {
                                    await backendService.removeAttachment(
                                      widget.doctype,
                                      widget.name,
                                      attachment["name"],
                                    );
                                    _refresh();
                                    widget.callback();
                                    showSnackBar('Attachment removed', context);
                                  },
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
