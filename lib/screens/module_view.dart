import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';
import '../utils/response_models.dart';
import '../main.dart';
import './doctype_view.dart';

class ModuleView extends StatelessWidget {
  static const _supportedModules = ['Support', 'CRM'];
  final user = localStorage.getString('user');
  static const popupOptions = const ["Logout"];

  Future _fetchSideBarItems(context) async {
    final response2 = await dio.post(
      '/method/frappe.desk.desktop.get_desk_sidebar_items',
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response2.statusCode == 200) {
      return DioGetSideBarItemsResponse.fromJson(response2.data).values;
    } else if (response2.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  void _choiceAction(String choice, context) {
    if (choice == "Logout") {
      logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchSideBarItems(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var modules = snapshot.data["Modules"];
          var modulesWidget = modules.where((m) {
            return _supportedModules.contains(m["name"]);
          }).map<Widget>((m) {
            return ListTile(
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
            );
          }).toList();
          return Scaffold(
            appBar: AppBar(
              leading: PopupMenuButton<String>(
                onSelected: (choice) => _choiceAction(choice, context),
                icon: CircleAvatar(
                  child: Text(
                    user[0].toUpperCase(),
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Palette.bgColor,
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