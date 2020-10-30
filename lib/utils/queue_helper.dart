import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/config_helper.dart';
import 'package:hive/hive.dart';

import '../services/storage_service.dart';
import '../service_locator.dart';

class QueueHelper {
  static Box getQueueContainer() {
    return locator<StorageService>().getBox('queue');
  }

  static putAt(int index, dynamic value) {
    List l = getQueueItems();
    l.remove(index);
    l.insert(index, value);
    getQueueContainer().put(
      ConfigHelper().primaryCacheKey,
      l,
    );
  }

  static add(dynamic value) {
    List l = getQueueItems();

    l.add(value);

    getQueueContainer().put(
      ConfigHelper().primaryCacheKey,
      l,
    );
  }

  static List getQueueItems() {
    return getQueueContainer().get(
      ConfigHelper().primaryCacheKey,
      defaultValue: [],
    );
  }

  static getAt(int index) {
    List l = getQueueItems();
    return l[index];
  }

  static Future deleteAt(int index) async {
    List l = getQueueItems();
    l.removeAt(index);
    await getQueueContainer().put(
      ConfigHelper().primaryCacheKey,
      l,
    );
  }

  static Future processQueue() async {
    var qc = QueueHelper.getQueueContainer();
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
