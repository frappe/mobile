import 'package:frappe_app/utils/backend_service.dart';

import '../services/storage_service.dart';
import '../service_locator.dart';

class QueueHelper {
  static getQueueContainer() async {
    await locator<StorageService>().initStorage();
    var queueContainer = await locator<StorageService>().initBox('queue');
    return queueContainer;
  }

  static Future putAt(int index, dynamic value) async {
    await locator<StorageService>().initStorage();
    var queueContainer = await locator<StorageService>().initBox('queue');
    queueContainer.putAt(index, value);
  }

  static Future add(dynamic value) async {
    await locator<StorageService>().initStorage();
    var queueContainer = await locator<StorageService>().initBox('queue');
    queueContainer.add(value);
  }

  static getAt(int index) async {
    await locator<StorageService>().initStorage();
    var queueContainer = await locator<StorageService>().initBox('queue');
    return queueContainer.getAt(index);
  }

  static Future deleteAt(int index) async {
    await locator<StorageService>().initStorage();
    var queueContainer = await locator<StorageService>().initBox('queue');
    queueContainer.deleteAt(index);
  }

  static Future processQueue() async {
    var qc = await QueueHelper.getQueueContainer();
    var queueLength = qc.length;
    var l = List.generate(queueLength, (index) => 0);

    for (var i in l) {
      var q = await getAt(i);
      await processQueueItem(q, i);
    }
  }

  static Future processQueueItem(var q, int index) async {
    try {
      var response = await BackendService.saveDocs(
        q["doctype"],
        q["data"][0],
      );

      if (response.statusCode == 200) {
        await QueueHelper.deleteAt(index);
      } else {
        await QueueHelper.putAt(
          index,
          {
            ...q,
            "error": response.statusMessage,
          },
        );
      }
    } catch (e) {
      print(e);
      QueueHelper.putAt(
        index,
        {
          ...q,
          "error": e.statusMessage,
        },
      );
    }
  }
}
