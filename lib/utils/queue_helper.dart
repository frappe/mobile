import '../services/storage_service.dart';
import '../service_locator.dart';

class QueueHelper {
  static var queueContainer = locator<StorageService>().getBox('queue');

  static var queueLength = queueContainer.length;

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
}
