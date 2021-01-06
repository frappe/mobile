import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../utils/enums.dart';
import '../app/locator.dart';

import '../config/frappe_icons.dart';
import '../config/palette.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';

class CustomFilePicker extends StatefulWidget {
  final String doctype;
  final String name;
  final Function callback;

  CustomFilePicker({
    this.doctype,
    this.name,
    this.callback,
  });

  @override
  _FilePickerState createState() => _FilePickerState();
}

class _FilePickerState extends State<CustomFilePicker> {
  List<File> _files = [];

  void _openFileExplorer() async {
    try {
      _files = await FilePicker.platform.pickFiles(
            type: FileType.any,
          ) ??
          [];
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Palette.bgColor,
        child: Column(
          children: <Widget>[
            CardListTile(
              leading: FrappeFlatButton.small(
                buttonType: ButtonType.secondary,
                title: "Attach File",
                icon: FrappeIcons.small_add,
                onPressed: () => _openFileExplorer(),
              ),
              trailing: FrappeFlatButton.small(
                title: 'Upload',
                buttonType: ButtonType.primary,
                onPressed: _files != null && _files.isNotEmpty
                    ? () async {
                        await locator<Api>().uploadFile(
                          widget.doctype,
                          widget.name,
                          _files,
                        );
                        locator<NavigationService>().pop(true);
                        widget.callback();
                      }
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
                                setState(() {
                                  _files.removeAt(index);
                                });
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
      ),
    );
  }
}
