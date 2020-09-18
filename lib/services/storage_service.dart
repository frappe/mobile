import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  Box getBox(String name) {
    return Hive.box(name);
  }

  Future<Box> initBox(String name) {
    return Hive.openBox(name);
  }

  Future initStorage() {
    return Hive.initFlutter();
  }
}
