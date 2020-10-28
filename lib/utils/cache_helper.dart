import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../utils/config_helper.dart';
import '../utils/backend_service.dart';
import '../utils/helpers.dart';

import '../services/storage_service.dart';

import '../service_locator.dart';

class CacheHelper {
  static String generateKeyHash(String key) {
    return sha1.convert(utf8.encode(key)).toString();
  }

  static putCache(String secondaryKey, dynamic data) async {
    if (ConfigHelper().primaryCacheKey == null) {
      return;
    }

    await locator<StorageService>().initStorage();
    var cacheContainer = await locator<StorageService>().initBox('cache');

    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;
    var kHash = generateKeyHash(k);

    var v = {
      'timestamp': DateTime.now(),
      'data': data,
    };

    await cacheContainer.put(kHash, v);
  }

  static putAllCache(Map data) async {
    if (ConfigHelper().primaryCacheKey == null) {
      return;
    }

    await locator<StorageService>().initStorage();
    var cacheContainer = await locator<StorageService>().initBox('cache');

    var v = {};

    data.forEach(
      (key, value) {
        v[generateKeyHash(ConfigHelper().primaryCacheKey + "#@#" + key)] = {
          'timestamp': DateTime.now(),
          "data": value,
        };
      },
    );

    await cacheContainer.putAll(v);
  }

  static getCache(String secondaryKey) async {
    if (ConfigHelper().primaryCacheKey == null) {
      return {"data": null};
    }
    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;
    var keyHash = generateKeyHash(k);

    await locator<StorageService>().initStorage();
    var cacheContainer = await locator<StorageService>().initBox('cache');

    if (cacheContainer.get(keyHash) == null) {
      return {"data": null};
    }

    return cacheContainer.get(keyHash);
  }

  static Future remove(String secondaryKey) async {
    await locator<StorageService>().initStorage();
    var cacheContainer = await locator<StorageService>().initBox('cache');
    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;
    var keyHash = generateKeyHash(k);
    cacheContainer.delete(keyHash);
  }

  static cacheModule(String module) async {
    var syncContainer = await locator<StorageService>().initBox('sync');
    try {
      await syncContainer.put("cacheApi", false);
      var cache = {};
      var deskSideBarItems = await BackendService.getDeskSideBarItems();
      var doctypes = await BackendService.getDesktopPage(module);
      var activeDoctypes = getActivatedDoctypes(doctypes, module);

      cache["${module}Doctypes"] = doctypes;
      cache['deskSidebarItems'] = deskSideBarItems;

      var f = <Future>[];

      for (var doctype in activeDoctypes) {
        f.add(
          cacheDocListAndDoc(
            doctype["name"],
          ),
        );
        f.add(
          cacheLinkFields(doctype["name"]),
        );
        f.add(
          cacheDoctypeMeta(doctype["name"]),
        );
      }

      var result = await Future.wait(f);
      result.forEach(
        (element) {
          cache = {
            ...element,
            ...cache,
          };
        },
      );
      await putAllCache(cache);
      await syncContainer.put("cacheApi", true);
    } catch (e) {
      await syncContainer.put("cacheApi", true);
      print(e);
    }
  }

  static Future<Map> cacheDoctypeMeta(String doctype) async {
    var cache = {};
    try {
      var response = await BackendService.getDoctype(doctype);
      cache['${doctype}Meta'] = response;
    } catch (e) {
      print(e);
    }

    return cache;
  }

  static Future<Map> cacheLinkFields(String doctype) async {
    var cache = {};
    try {
      var f = <Future>[];
      var linkFieldDoctypes = await getLinkFields(doctype);

      for (var doctype in linkFieldDoctypes) {
        f.add(cacheLinkField(doctype));
      }

      var result = await Future.wait(f);

      result.forEach(
        (element) {
          cache = {
            ...element,
            ...cache,
          };
        },
      );
    } catch (e) {
      print(e);
    }

    return cache;
  }

  static Future<Map> cacheLinkField(String doctype) async {
    var cache = {};
    try {
      var linkData = await BackendService.searchLink(
        doctype: doctype,
        pageLength: 9999,
      );
      cache['${doctype}LinkFull'] = linkData;
    } catch (e) {
      print(e);
    }

    return cache;
  }

  static Future<Map> cacheDocListAndDoc(String doctype) async {
    var cache = {};
    var f = <Future>[];

    try {
      var docMeta = await BackendService.getDoctype(doctype);
      docMeta = docMeta["docs"][0];

      var docList = await BackendService.fetchList(
        doctype: doctype,
        fieldnames: generateFieldnames(doctype, docMeta),
        pageLength: 50,
        offset: 0,
        meta: docMeta,
      );

      cache['${doctype}List'] = docList;

      for (var doc in docList) {
        f.add(
          cacheDoc(
            doctype,
            doc["name"],
          ),
        );
      }

      var result = await Future.wait(f);

      result.forEach(
        (element) {
          cache = {
            ...element,
            ...cache,
          };
        },
      );
    } catch (e) {
      print(e);
    }

    return cache;
  }

  static Future<Map> cacheDoc(String doctype, String docName) async {
    var cache = {};
    try {
      var docForm = await BackendService.getdoc(doctype, docName);
      cache['$doctype$docName'] = docForm;
    } catch (e) {
      print(e);
    }
    return cache;
  }

  static Future<bool> shouldCacheApi() async {
    await locator<StorageService>().initStorage();
    var syncContainer = await locator<StorageService>().initBox('sync');
    var shouldCacheApi = syncContainer.get("cacheApi", defaultValue: true);

    return shouldCacheApi;
  }
}
