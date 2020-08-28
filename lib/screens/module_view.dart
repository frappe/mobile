import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frappe_app/screens/settings.dart';
import 'package:frappe_app/utils/http.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

import '../main.dart';
import '../config/palette.dart';
import '../widgets/card_list_tile.dart';
import '../utils/backend_service.dart';
import '../utils/helpers.dart';
import './doctype_view.dart';

class ModuleView extends StatefulWidget {
  @override
  _ModuleViewState createState() => _ModuleViewState();
}

class _ModuleViewState extends State<ModuleView> {
  final userId = Uri.decodeFull(localStorage.getString('userId'));
  static const popupOptions = const ["Settings", "Logout"];

  @override
  void initState() {
    super.initState();
    if (!localStorage.containsKey("${baseUrl}activeModules")) {
      localStorage.setString(
        "${baseUrl}activeModules",
        json.encode(
          {
            'CRM': ['Opportunity'],
            'Support': ['Issue'],
            'Projects': ['Task']
          },
        ),
      );
    }
  }

  void _choiceAction(String choice, context) async {
    if (choice == "Logout") {
      logout(context);
    } else if (choice == "Settings") {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    var backendService = BackendService(context);
    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: AppBar(
        title: Text('Modules'),
        elevation: 0,
        leading: PopupMenuButton<String>(
          onSelected: (choice) => _choiceAction(choice, context),
          icon: UserAvatar(
            uid: userId,
          ),
          itemBuilder: (BuildContext context) {
            return popupOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ),
      body: FutureBuilder(
        future: backendService.getDeskSideBarItems(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var activeModules = Map<String, List>.from(
              json.decode(
                localStorage.getString("${baseUrl}activeModules"),
              ),
            );
            var modules = snapshot.data["message"]["Modules"];
            var modulesWidget = modules.where((m) {
              return activeModules.keys.contains(m["name"]) &&
                  activeModules[m["name"]].length > 0;
            }).map<Widget>((m) {
              return Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
                child: CardListTile(
                  title: Text(m["label"]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return DoctypeView(m["name"]);
                        },
                      ),
                    );
                  },
                ),
              );
            }).toList();
            return ListView(
              children: modulesWidget,
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
