import 'package:flutter/material.dart';
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
      : '';

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
            setState(() {});
          },
          child: FutureBuilder(
            future: HomeViewModel().getData(
              connectionStatus: connectionStatus,
              currentModule: currentModule,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                var activeModules = ConfigHelper().activeModules;

                if (activeModules == null) {
                  return _activateModules();
                }

                var activeDoctypes = getActivatedDoctypes(
                  snapshot.data,
                  currentModule,
                );

                if (activeDoctypes.isEmpty) {
                  return _activateDoctypes();
                }

                var doctypesWidget = _generateChildren(activeDoctypes);

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

  List<Widget> _generateChildren(List<CardItemLink> activeDoctypes) {
    return activeDoctypes.map<Widget>((m) {
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

  Widget _activateModules() {
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
}
