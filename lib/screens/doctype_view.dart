import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/widgets/card_list_tile.dart';

import '../utils/enums.dart';
import '../app.dart';

class DoctypeView extends StatelessWidget {
  static const _supportedDoctypes = ['Issue', 'Opportunity'];

  final String module;

  DoctypeView(this.module);

  @override
  Widget build(BuildContext context) {
    var backendService = BackendService(context);
    return FutureBuilder(
      future: backendService.getDesktopPage(module, context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var doctypes = snapshot.data["message"]["cards"]["items"][0]["links"];
          var modulesWidget = doctypes.where((m) {
            return _supportedDoctypes.contains(m["name"]);
          }).map<Widget>((m) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
              child: CardListTile(
                title: Text(m["label"]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Router(
                          doctype: m["name"],
                          viewType: ViewType.list,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }).toList();
          return Scaffold(
            backgroundColor: Palette.bgColor,
            appBar: AppBar(
              title: Text(module),
              elevation: 0,
            ),
            body: ListView(
              children: modulesWidget,
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
