// import 'package:flutter/material.dart';
// import 'package:frappe_app/model/offline_storage.dart';
// import 'package:frappe_app/views/form_view/form_view.dart';
// import 'package:provider/provider.dart';

// import '../config/frappe_icons.dart';
// import '../config/palette.dart';

// import '../widgets/card_list_tile.dart';

// import '../utils/frappe_alert.dart';
// import '../utils/frappe_icon.dart';
// import '../utils/enums.dart';
// import '../utils/helpers.dart';
// import '../model/queue.dart';

// class QueueList extends StatefulWidget {
//   @override
//   _QueueListState createState() => _QueueListState();
// }

// class _QueueListState extends State<QueueList> {
//   void _refresh() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     var connectionStatus = Provider.of<ConnectivityStatus>(
//       context,
//     );

//     return Scaffold(
//       backgroundColor: Palette.bgColor,
//       appBar: AppBar(
//         title: Text('Queue'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           _refresh();
//         },
//         child: Builder(
//           builder: (
//             context,
//           ) {
//             var l = Queue.getQueueItems();
//             if (l.length < 1) {
//               return Padding(
//                 padding: EdgeInsets.all(8),
//                 child: Text(
//                   "Queue is Empty",
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Palette.secondaryTxtColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               );
//             }
//             return ListView.builder(
//               itemCount: l.length,
//               itemBuilder: (context, index) {
//                 var q = l[index];
//                 return CardListTile(
//                   leading: IconButton(
//                     icon: Icon(Icons.sync),
//                     onPressed: () async {
//                       var isOnline = await verifyOnline();
//                       if (connectionStatus == ConnectivityStatus.offline &&
//                           !isOnline) {
//                         FrappeAlert.errorAlert(
//                           title: 'Cant Sync, App is offline',
//                           context: context,
//                         );
//                         return;
//                       } else if (q["error"] != null) {
//                         FrappeAlert.errorAlert(
//                           title:
//                               "There was some error while processing this item",
//                           context: context,
//                         );
//                         return;
//                       }

//                       await Queue.processQueueItem(q, index);
//                       _refresh();
//                     },
//                   ),
//                   title: Text(q['title'] ?? ""),
//                   subtitle: Row(
//                     children: [
//                       Text(
//                         q['doctype'],
//                       ),
//                       VerticalDivider(),
//                       Text(
//                         q["type"],
//                       ),
//                       VerticalDivider(),
//                       if (q["error"] != null)
//                         FrappeIcon(
//                           FrappeIcons.error,
//                           size: 20,
//                         ),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     onPressed: () {
//                       Queue.deleteAt(index);
//                       setState(() {});
//                     },
//                     icon: Icon(Icons.clear),
//                   ),
//                   onTap: () async {
//                     q["qIdx"] = index;
//                     var meta = await OfflineStorage.getMeta(q['doctype']);

//                     Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) {
//                         return FormView(
//                           queued: true,
//                           queuedData: q,
//                           meta: meta.docs[0],
//                         );
//                       },
//                     ));
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
