import 'package:frappe_app/utils/backend_service.dart';

import '../services/storage_service.dart';
import '../service_locator.dart';

class QueueHelper {
  static var queueContainer = locator<StorageService>().getBox('queue');

  static Future putAt(int index, dynamic value) async {
    queueContainer.putAt(index, value);
  }

  static Future add(dynamic value) async {
    queueContainer.add(value);
  }

  static getAt(int index) {
    return queueContainer.getAt(index);
  }

  static Future deleteAt(int index) async {
    queueContainer.deleteAt(index);
  }

  static Future processQueue() async {
    for (var i
        in List.generate(QueueHelper.queueContainer.length, (index) => index)) {
      var q = getAt(i);
      await processQueueItem(q, i);
    }
  }

  static Future processQueueItem(var q, int index) async {
    if (q["type"] == "create") {
      var response = await BackendService.saveDocs(q["doctype"], q["data"][0]);

      if (response.statusCode == 200) {
        QueueHelper.deleteAt(index);
      }
    } else if (q["type"] == "update") {
      var response = await BackendService.updateDoc(
        q["doctype"],
        q["name"],
        q["data"][0],
      );

      if (response.statusCode == 200) {
        QueueHelper.deleteAt(index);
      }
    }
  }
}
