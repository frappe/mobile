import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:provider/provider.dart';

import '../../datamodels/desktop_page_response.dart';
import '../../config/palette.dart';
import '../../views/home/home_viewmodel.dart';
import '../../services/navigation_service.dart';

import '../../app/router.gr.dart';
import '../../app/locator.dart';

import '../../utils/helpers.dart';
import '../../utils/config_helper.dart';
import '../../utils/enums.dart';

import '../../widgets/frappe_button.dart';
import '../../widgets/header_app_bar.dart';
import '../../widgets/card_list_tile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  var currentModule = ConfigHelper().activeModules != null
      ? ConfigHelper().activeModules.keys.first
      : null;

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
        subtitle: currentModule ?? "",
        showSecondaryLeading: true,
        body: RefreshIndicator(
          onRefresh: () async {
            _refresh();
          },
          child: currentModule == null
              ? _activateModules(() {
                  setState(() {
                    currentModule = ConfigHelper().activeModules.keys.first;
                  });
                })
              : FutureBuilder(
                  future: HomeViewModel().getData(
                    connectionStatus: connectionStatus,
                    currentModule: currentModule,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      var filteredActiveDoctypes =
                          HomeViewModel().filterActiveDoctypes(
                        desktopPage: snapshot.data,
                        module: currentModule,
                      );

                      if (filteredActiveDoctypes
                              .message.shortcuts.items.isEmpty &&
                          filteredActiveDoctypes.message.cards.items.isEmpty) {
                        return _activateDoctypes();
                      }

                      return ListView(
                        padding: EdgeInsets.zero,
                        children: _generateChildren(filteredActiveDoctypes),
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

  Widget _heading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
        horizontal: 16,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _subHeading(String title) {
    return ListTile(
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _shortcut(String label) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 8.0,
      ),
      child: CardListTile(
        title: Text(label),
        onTap: () {
          locator<NavigationService>().navigateTo(
            Routes.customListView,
            arguments: CustomListViewArguments(
              doctype: label,
            ),
          );
        },
      ),
    );
  }

  Widget _item(String label) {
    return ListTile(
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      title: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: FrappePalette.grey[100],
                ),
                width: 20,
                height: 20,
              ),
              Icon(
                Icons.circle,
                color: FrappePalette.grey[800],
                size: 6,
              ),
            ],
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            label,
          ),
        ],
      ),
      onTap: () {
        locator<NavigationService>().navigateTo(
          Routes.customListView,
          arguments: CustomListViewArguments(
            doctype: label,
          ),
        );
      },
    );
  }

  List<Widget> _generateChildren(DesktopPageResponse desktopPage) {
    List<Widget> widgets = [];

    if (desktopPage.message.shortcuts.items.isNotEmpty) {
      widgets.add(
        SizedBox(
          height: 20,
        ),
      );
      widgets.add(
        _heading("Your Shortcuts"),
      );

      widgets.addAll(desktopPage.message.shortcuts.items.map<Widget>(
        (item) {
          return _shortcut(
            item.label,
          );
        },
      ).toList());

      widgets.add(
        SizedBox(
          height: 20,
        ),
      );
    }

    if (desktopPage.message.cards.items.isNotEmpty) {
      widgets.add(
        _heading("Masters"),
      );

      desktopPage.message.cards.items.forEach(
        (item) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.5,
                    color: FrappePalette.grey[400],
                  ),
                  borderRadius: BorderRadius.circular(
                    6.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      _subHeading(
                        item.label,
                      ),
                      ...item.links.map(
                        (link) {
                          return _item(
                            link.label,
                          );
                        },
                      ).toList()
                    ],
                  ),
                ),
              ),
            ),
          );

          widgets.add(
            SizedBox(
              height: 15,
            ),
          );
        },
      );
    }

    return widgets;
  }

  Drawer _buildDrawer(
    ConnectivityStatus connectionStatus,
  ) {
    return Drawer(
      child: FutureBuilder(
        future: HomeViewModel().getActiveModules(connectionStatus),
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

  Widget _activateModules(Function refresh) {
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
                  refresh();
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

  Widget _activateDoctypes() {
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
                _refresh();
              }
            },
            title: 'Activate Doctypes',
            buttonType: ButtonType.primary,
          )
        ],
      ),
    );
  }
}
