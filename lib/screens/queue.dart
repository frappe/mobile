import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';

import '../config/palette.dart';

import '../widgets/card_list_tile.dart';

import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/queue_helper.dart';

class QueueList extends StatefulWidget {
  @override
  _QueueListState createState() => _QueueListState();
}

class _QueueListState extends State<QueueList> {
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: AppBar(
        title: Text('Queue'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        child: ListView.builder(
          itemCount: QueueHelper.queueLength,
          itemBuilder: (context, index) {
            var q = QueueHelper.getAt(index);
            return CardListTile(
              leading: IconButton(
                icon: Icon(Icons.cloud_upload),
                onPressed: () async {
                  if (connectionStatus == ConnectivityStatus.offline) {
                    showSnackBar('Cant Sync, App is offline', context);
                    return;
                  }
                  if (q["type"] == "create") {
                    var response = await backendService.saveDocs(
                        q["doctype"], q["data"][0]);

                    if (response.statusCode == 200) {
                      QueueHelper.deleteAt(index);
                      _refresh();
                    }
                  } else if (q["type"] == "update") {
                    var response = await backendService.updateDoc(
                      q["doctype"],
                      q["name"],
                      q["data"][0],
                    );

                    if (response.statusCode == 200) {
                      QueueHelper.deleteAt(index);
                      _refresh();
                    }
                  }
                },
              ),
              title: Text(q['title']),
              subtitle: Row(
                children: [
                  Text(
                    q['doctype'],
                  ),
                  VerticalDivider(),
                  Text(
                    q["type"],
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  QueueHelper.deleteAt(index);
                  setState(() {});
                },
                icon: Icon(Icons.clear),
              ),
              onTap: () {
                q["qIdx"] = index;
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Router(
                        viewType: ViewType.form,
                        doctype: q['doctype'],
                        queued: true,
                        queuedData: q,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
