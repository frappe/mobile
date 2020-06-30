import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/widgets/card_list_tile.dart';

import '../utils/helpers.dart';
import '../utils/enums.dart';
import '../utils/http.dart';
import '../utils/response_models.dart';
import '../app.dart';

class DoctypeView extends StatelessWidget {
  static const _supportedDoctypes = ['Issue', 'Opportunity'];

  final String module;

  DoctypeView(this.module);

  Future _fetchDoctypes(module, context) async {
    final response2 = await dio.post(
      '/method/frappe.desk.desktop.get_desktop_page',
      data: {
        'page': module,
      },
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response2.statusCode == 200) {
      return DioDesktopPageResponse.fromJson(response2.data).values;
    } else if (response2.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDoctypes(module, context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var doctypes = snapshot.data["cards"]["items"][0]["links"];
          var modulesWidget = doctypes.where((m) {
            return _supportedDoctypes.contains(m["name"]);
          }).map<Widget>((m) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
              child: CardListTile(
                title: Text(m["label"]),
                onTap: () {
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
          return Scaffold(
            backgroundColor: Palette.bgColor,
            appBar: AppBar(
              elevation: 0,
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
