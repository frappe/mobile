import 'package:flutter/material.dart';

import '../utils/helpers.dart';

class ViewAttachments extends StatelessWidget {
  final List data;

  ViewAttachments(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: data.map<Widget>((attachment) {
          var file = attachment["file_name"];
          var ext = file.split('.').last;
          var fileName = file.split('.').first;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(ext),
              ),
              onTap: () {
                // downloadFile(attachment["file_url"]);
              },
              title: Text(fileName),
            ),
          );
        }).toList(),
      ),
    );
  }
}
