import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/screens/settings.dart';
import 'package:frappe_app/utils/http.dart';
import 'package:frappe_app/widgets/frappe_button.dart';

import '../app.dart';
import '../config/palette.dart';
import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../widgets/card_list_tile.dart';

class DoctypeView extends StatefulWidget {
  final String module;

  DoctypeView(this.module);

  @override
  _DoctypeViewState createState() => _DoctypeViewState();
}

class _DoctypeViewState extends State<DoctypeView> {
  @override
  Widget build(BuildContext context) {
    var backendService = BackendService(context);

    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: AppBar(
        title: Text(widget.module),
      ),
      body: FutureBuilder(
        future: backendService.getDesktopPage(widget.module, context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var activeModules = Map<String, List>.from(
              json.decode(
                localStorage.getString("${baseUrl}activeModules"),
              ),
            );
            var doctypes = [];

            snapshot.data["message"]["cards"]["items"].forEach((item) {
              doctypes.addAll(item["links"]);
            });
            var doctypesWidget = doctypes.where((m) {
              return activeModules[widget.module].contains(
                m["name"],
              );
            });

            if (doctypesWidget.isEmpty) {
              return Container(
                color: Colors.white,
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        'No Doctypes are yet Activated or you dont have permission'),
                    FrappeFlatButton(
                        onPressed: () async {
                          var nav = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Settings();
                              },
                            ),
                          );

                          if (nav) {
                            setState(() {});
                          }
                        },
                        title: 'Activate Doctypes',
                        buttonType: ButtonType.primary)
                  ],
                ),
              );
            }
            doctypesWidget = doctypesWidget.map<Widget>((m) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 8.0,
                ),
                child: CardListTile(
                  title: Text(m["label"]),
                  onTap: () async {
                    await processData(m["name"], context);
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
            return ListView(
              children: doctypesWidget,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
