import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/datamodels/desktop_page_response.dart';
import 'package:frappe_app/widgets/header_app_bar.dart';
import 'package:provider/provider.dart';

import '../config/palette.dart';
import '../datamodels/desk_sidebar_items_response.dart';

import '../app/router.gr.dart';
import '../app/locator.dart';

import '../services/navigation_service.dart';
import '../services/api/api.dart';

import '../utils/cache_helper.dart';
import '../utils/frappe_alert.dart';
import '../utils/helpers.dart';
import '../utils/config_helper.dart';
import '../utils/enums.dart';

import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  var currentModule = ConfigHelper().activeModules != null
      ? ConfigHelper().activeModules.keys.first
      : '';

  Future _getActiveModules(ConnectivityStatus connectionStatus) async {
    DeskSidebarItemsResponse deskSidebarItems;
    var activeModules;
    if (ConfigHelper().activeModules != null) {
      activeModules = ConfigHelper().activeModules;
    } else {
      activeModules = {};
    }

    var isOnline = await verifyOnline();

    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var deskSidebarItemsCache =
          await CacheHelper.getCache('deskSidebarItems');
      deskSidebarItemsCache = deskSidebarItemsCache["data"];

      if (deskSidebarItemsCache != null) {
        deskSidebarItems =
            DeskSidebarItemsResponse.fromJson(deskSidebarItemsCache);
      } else {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      deskSidebarItems = await locator<Api>().getDeskSideBarItems();
    }

    var modules = deskSidebarItems.message.where((m) {
      return activeModules.keys.contains(m.name) &&
          activeModules[m.name].length > 0;
    }).toList();

    return modules;
  }

  Future<DesktopPageResponse> _getData(
    ConnectivityStatus connectionStatus,
  ) async {
    DesktopPageResponse desktopPage;

    var isOnline = await verifyOnline();

    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var moduleDoctypes =
          await CacheHelper.getCache('${currentModule}Doctypes');
      moduleDoctypes = moduleDoctypes["data"];

      if (moduleDoctypes != null) {
        desktopPage = DesktopPageResponse.fromJson(moduleDoctypes);
      } else {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
    } else {
      desktopPage = await locator<Api>().getDesktopPage(currentModule);
    }

    return desktopPage;
  }

  Drawer _buildDrawer(
    ConnectivityStatus connectionStatus,
  ) {
    return Drawer(
      child: FutureBuilder(
        future: _getActiveModules(connectionStatus),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> listItems = [
              Container(
                height: 30,
              ),
              ListTile(
                title: Text('MODULES'),
              ),
            ];
            snapshot.data.forEach((element) {
              listItems.add(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ListTile(
                  tileColor: currentModule == element.name
                      ? Palette.bgColor
                      : Colors.white,
                  title: Text(element.label),
                  onTap: () {
                    setState(() {
                      currentModule = element.name;
                    });
                    locator<NavigationService>().pop();
                  },
                ),
              ));
            });

            return ListView(
              children: listItems,
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var activeModules;
    if (ConfigHelper().activeModules != null) {
      activeModules = ConfigHelper().activeModules;
    } else {
      activeModules = {};
    }
    if (activeModules.keys.isEmpty) {
      return Scaffold(
        body: HeaderAppBar(
          isRoot: true,
          subtitle: '',
          showSecondaryLeading: true,
          body: Center(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Activate Modules'),
                  FrappeFlatButton(
                    onPressed: () async {
                      var nav = await locator<NavigationService>()
                          .navigateTo(Routes.activateModules);

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
          ),
        ),
      );
    }

    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return Scaffold(
      key: _drawerKey,
      backgroundColor: Palette.bgColor,
      drawer: _buildDrawer(
        connectionStatus,
      ),
      body: HeaderAppBar(
        isRoot: true,
        subtitle: currentModule,
        showSecondaryLeading: true,
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder(
            future: _getData(
              connectionStatus,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
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
                              var nav = await locator<NavigationService>()
                                  .navigateTo(Routes.activateModules);

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

                var activeDoctypes = getActivatedDoctypes(
                  snapshot.data,
                  currentModule,
                );

                if (activeDoctypes.isEmpty) {
                  return Container(
                    margin: EdgeInsets.zero,
                    color: Colors.white,
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'No Doctypes are yet Activated or you dont have permission',
                        ),
                        FrappeFlatButton(
                          onPressed: () async {
                            var nav = await locator<NavigationService>()
                                .navigateTo(Routes.activateModules);

                            if (nav) {
                              setState(() {});
                            }
                          },
                          title: 'Activate Doctypes',
                          buttonType: ButtonType.primary,
                        )
                      ],
                    ),
                  );
                }
                var doctypesWidget = activeDoctypes.map<Widget>((m) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      top: 8.0,
                    ),
                    child: CardListTile(
                      title: Text(m.label),
                      onTap: () {
                        locator<NavigationService>().navigateTo(
                          Routes.customListView,
                          arguments: CustomListViewArguments(
                            doctype: m.label,
                          ),
                        );
                      },
                    ),
                  );
                }).toList();
                return ListView(
                  padding: EdgeInsets.zero,
                  children: doctypesWidget,
                );
              } else if (snapshot.hasError) {
                return handleError(snapshot.error);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
