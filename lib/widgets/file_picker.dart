import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frappe_app/config/frappe_icons.dart';

import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../config/palette.dart';
import 'frappe_button.dart';
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
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  ? () {
                      backendService.uploadFile(
                        widget.doctype,
                        widget.name,
                        _files,
                      );
                      widget.callback();
                      Navigator.of(context).pop();
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
    );
  }
}
