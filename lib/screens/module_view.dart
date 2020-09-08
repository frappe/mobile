import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frappe_app/screens/activate_modules.dart';
import 'package:frappe_app/screens/queue.dart';
import 'package:frappe_app/screens/settings.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/http.dart';
import 'package:frappe_app/widgets/frappe_button.dart';
import 'package:frappe_app/widgets/user_avatar.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  static const popupOptions = const ["Settings", "Logout", "Queue"];
  BackendService backendService;

  @override
  void initState() {
    backendService = BackendService(context);
    super.initState();
  }

  Future _getData() {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    if (connectionStatus == ConnectivityStatus.offline) {
      return Future.delayed(
          Duration(seconds: 1), () => getCache('deskSidebarItems')["data"]);
    } else {
      return backendService.getDeskSideBarItems(context);
    }
  }

  void _choiceAction(String choice, context) async {
    if (choice == "Logout") {
      logout(context);
    } else if (choice == "Settings") {
      // var nav = await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return Settings();
      //     },
      //   ),
      // );

      // if (nav) {
      //   setState(() {});
      // }
    } else if (choice == "Queue") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return QueueList();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
          future: _getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var activeModules;
              if (localStorage.containsKey("${baseUrl}activeModules")) {
                activeModules = Map<String, List>.from(
                  json.decode(
                    localStorage.getString("${baseUrl}activeModules"),
                  ),
                );
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
                var syncDate;
                var c = getCache('module${m["name"]}');

                if (c == null) {
                  syncDate = "Not Synced";
                } else {
                  syncDate = timeago.format(
                    c["timestamp"],
                  );
                }
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
                  child: CardListTile(
                    title: Text(m["label"]),
                    trailing: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_download,
                          ),
                          Text(
                            syncDate,
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                      onPressed: () async {
                        await cacheModule(m["name"], context);
                        showSnackBar('${m["name"]} is downloaded', context);
                        setState(() {});
                      },
                    ),
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
      ),
    );
  }
}
