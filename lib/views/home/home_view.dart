import 'package:flutter/material.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:provider/provider.dart';

import '../../model/desktop_page_response.dart';
import '../../views/home/home_viewmodel.dart';
import '../../services/navigation_service.dart';

import '../../config/frappe_palette.dart';
import '../../config/palette.dart';

import '../../app/locator.dart';

import '../../utils/enums.dart';

import '../../widgets/header_app_bar.dart';
import '../../widgets/card_list_tile.dart';
import '../base_view.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return BaseView<HomeViewModel>(
      onModelReady: (model) {
        model.getData();
      },
      onModelClose: (model) {
        model.error = null;
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: Palette.bgColor,
        drawer: _buildDrawer(
          connectionStatus: connectionStatus,
          model: model,
        ),
        body: HeaderAppBar(
          isRoot: true,
          subtitle: model.currentModule ?? "",
          showSecondaryLeading: true,
          body: RefreshIndicator(
            onRefresh: () async {
              model.refresh(connectionStatus);
            },
            child: model.state == ViewState.busy
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Builder(
                    builder: (
                      context,
                    ) {
                      if (model.error != null) {
                        return handleError(model.error);
                      }
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: _generateChildren(model.desktopPage),
                      );
                    },
                  ),
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

  Widget _shortcut({
    @required ShortcutItem item,
    HomeViewModel model,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 8.0,
      ),
      child: CardListTile(
        title: Text(item.label),
        onTap: () {
          model.navigateToView(
            item.linkTo,
          );
        },
      ),
    );
  }

  Widget _item({
    @required CardItemLink item,
    @required HomeViewModel model,
  }) {
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
          Expanded(
            child: Text(
              item.label,
            ),
          ),
        ],
      ),
      onTap: () {
        model.navigateToView(
          item.linkTo,
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
            item,
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
                            link,
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

  Drawer _buildDrawer({
    @required ConnectivityStatus connectionStatus,
    @required HomeViewModel model,
  }) {
    return Drawer(
      child: model.state == ViewState.busy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Builder(
              builder: (context) {
                List<Widget> listItems = [
                  Container(
                    height: 30,
                  ),
                  ListTile(
                    title: Text('MODULES'),
                  ),
                ];
                model.modules.forEach((element) {
                  listItems.add(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListTile(
                      tileColor: model.currentModule == element.name
                          ? Palette.bgColor
                          : Colors.white,
                      title: Text(element.label),
                      onTap: () {
                        model.switchModule(
                          element.name,
                        );

                        locator<NavigationService>().pop();
                      },
                    ),
                  ));
                });

                return ListView(
                  children: listItems,
                );
              },
            ),
    );
  }
}
