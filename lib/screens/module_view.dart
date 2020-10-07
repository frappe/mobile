import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/utils/dio_helper.dart';
import 'package:frappe_app/utils/helpers.dart';

import 'doctype_view.dart';

import '../screens/activate_modules.dart';
import '../screens/no_internet.dart';

import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';

import '../config/palette.dart';

import '../utils/config_helper.dart';
import '../utils/enums.dart';
import '../utils/backend_service.dart';

class ModuleView extends StatefulWidget {
  @override
  _ModuleViewState createState() => _ModuleViewState();
}

class _ModuleViewState extends State<ModuleView> {
  Future _getData() {
    return BackendService.getDeskSideBarItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: AppBar(
        title: Text('Modules'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
          future: _getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data["success"] == false) {
                return NoInternet();
              }
              var activeModules;
              if (ConfigHelper().activeModules != null) {
                activeModules = ConfigHelper().activeModules;
              } else {
                activeModules = {};
              }
              if (activeModules.keys.isEmpty) {
                return Center(
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Activate Modules'),
                        FrappeFlatButton(
                          onPressed: () async {
                            var nav = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ActivateModules();
                                },
                              ),
                            );

                            if (nav) {
                              setState(() {});
                            }
                          },
                          title: 'Activate Modules',
                          buttonType: ButtonType.primary,
                        )
                      ],
                    ),
                  ),
                );
              }
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
                    // trailing: IconButton(
                    //   padding: EdgeInsets.zero,
                    //   icon: Icon(
                    //     Icons.file_download,
                    //   ),
                    //   onPressed: () async {
                    //     await CacheHelper.cacheModule(m["name"]);
                    //     FrappeAlert.infoAlert(
                    //       title: '${m["name"]} is Downloaded',
                    //       context: context,
                    //     );
                    //     setState(() {});
                    //   },
                    // ),
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
              var error = (snapshot.error as Response);
              if (error.statusCode == 403) {
                handle403();
              } else {
                return Text("${snapshot.error}");
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
