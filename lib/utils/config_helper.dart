import '../services/storage_service.dart';

import '../service_locator.dart';

class ConfigHelper {
  static var configContainer = locator<StorageService>().getBox('config');

  bool get isLoggedIn => configContainer.get(
        'isLoggedIn',
        defaultValue: false,
      );

  Map get activeModules => configContainer.get(
        "${baseUrl}activeModules",
      );

  String get userId => Uri.decodeFull(configContainer.get(
        'userId',
      ));

  String get user => configContainer.get(
        'user',
      );

  String get primaryCacheKey => "$baseUrl$userId";

  String get version => configContainer.get(
        'version',
      );

  String get baseUrl => configContainer.get(
        'baseUrl',
      );

  Uri get uri => Uri.parse(baseUrl);

  static Future set(String k, dynamic v) async {
    configContainer.put(k, v);
  }

  static Future clear() async {
    configContainer.clear();
  }

  static Future remove(String k) async {
    configContainer.delete(k);
  }
}
