import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/app/router.gr.dart';
import 'package:frappe_app/services/navigation_service.dart';
import 'package:provider/provider.dart';

import '../app/locator.dart';
import '../datamodels/desktop_page_response.dart';
import '../services/api/api.dart';
import '../app.dart';
import '../config/palette.dart';
import '../screens/activate_modules.dart';

import '../utils/cache_helper.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';

import '../widgets/card_list_tile.dart';
import '../widgets/frappe_button.dart';

class DoctypeView extends StatefulWidget {
  final String module;

  DoctypeView(this.module);

  @override
  _DoctypeViewState createState() => _DoctypeViewState();
}

class _DoctypeViewState extends State<DoctypeView> {
  bool offline = false;

  Future<DesktopPageResponse> _getData() async {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    DesktopPageResponse desktopPage;

    var isOnline = await verifyOnline();

    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      offline = true;
      var response = await CacheHelper.getCache('${widget.module}Doctypes');
      response = response["data"];
      if (response == null) {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
      desktopPage = DesktopPageResponse.fromJson(response);
    } else {
      offline = false;
      desktopPage = await locator<Api>().getDesktopPage(widget.module);
    }

    return desktopPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: AppBar(
        elevation: 0.6,
        title: Text(widget.module),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
          future: _getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var activeDoctypes = getActivatedDoctypes(
                snapshot.data,
                widget.module,
              );

              if (activeDoctypes.isEmpty) {
                return Container(
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
                        Routes.customRouter,
                        arguments: CustomRouterArguments(
                          doctype: m.name,
                          viewType: ViewType.list,
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
              return handleError(snapshot.error, true);
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
