import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../config/palette.dart';
import '../utils/enums.dart';
import '../utils/http.dart';
import '../widgets/button.dart';
import '../widgets/card_list_tile.dart';

class CustomFilePicker extends StatefulWidget {
  final String doctype;
  final String name;
  final Function callback;

  CustomFilePicker({this.doctype, this.name, this.callback});

  @override
  _FilePickerState createState() => _FilePickerState();
}

class _FilePickerState extends State<CustomFilePicker> {
  List<File> _files = [];
  bool _loadingPath = false;

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _files = await FilePicker.getMultiFile(
            type: FileType.any,
          ) ??
          [];
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
    });
  }

  _uploadFile() async {
    for (File file in _files) {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "docname": widget.name,
        "doctype": widget.doctype,
        "is_private": 1,
        "folder": "Home/Attachments"
      });

      var response = await dio.post("/method/upload_file", data: formData);
      if (response.statusCode != 200) {
        throw Exception('Failed to load album');
      }
    }

    widget.callback();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.bgColor,
      child: Column(
        children: <Widget>[
          CardListTile(
            leading: Button(
              buttonType: ButtonType.secondary,
              title: "Attach File",
              icon: Icons.add,
              onPressed: () => _openFileExplorer(),
            ),
            trailing: Button(
              title: 'Upload',
              buttonType: ButtonType.primary,
              onPressed: _files != null && _files.isNotEmpty
                  ? () => _uploadFile()
                  : null,
            ),
          ),
          _files.isNotEmpty
              ? Expanded(
                  child: ListView(
                    children: _files.asMap().entries.map(
                      (entry) {
                        var file = entry.value;
                        var index = entry.key;

                        String fileName = file.path.split('/').last;
                        String ext = fileName.split('.').last;

                        return CardListTile(
                          leading: CircleAvatar(
                            child: Text(ext.toUpperCase()),
                          ),
                          title: Text(fileName),
                          trailing: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _files.removeAt(index);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )
              : CardListTile(
                  title: Text(
                    'No File Selected',
                    style: Palette.altTextStyle,
                  ),
                ),
        ],
      ),
    );
  }
}
