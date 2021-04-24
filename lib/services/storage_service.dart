import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class StorageService {
  Box getHiveBox(String name) {
    return Hive.box(name);
  }

  Future<Box> initHiveBox(String name) {
    return Hive.openBox(name);
  }

  Future initHiveStorage() {
    return Hive.initFlutter();
  }

  putSharedPrefBoolValue(String key, bool value) async {
    var _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(key, value);
  }

  Future<bool?> getSharedPrefBoolValue(String key) async {
    var _prefs = await SharedPreferences.getInstance();
    await _prefs.reload();
    return _prefs.getBool(key);
  }
}
