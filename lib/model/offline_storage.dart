import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/constants.dart';

import '../utils/config_helper.dart';
import '../utils/helpers.dart';

import '../services/storage_service.dart';

import '../app/locator.dart';

class OfflineStorage {
  static String generateKeyHash(String key) {
    return sha1.convert(utf8.encode(key)).toString();
  }

  static putItem(String secondaryKey, dynamic data) async {
    if (ConfigHelper().primaryCacheKey == null) {
      return;
    }

    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;
    var kHash = generateKeyHash(k);

    var v = {
      'timestamp': DateTime.now(),
      'data': data,
    };

    await locator<StorageService>().getBox('offline').put(kHash, v);
  }

  static putAllItems(Map data, [bool isIsolate = false]) async {
    if (ConfigHelper().primaryCacheKey == null) {
      return;
    }

    var v = {};

    data.forEach(
      (key, value) {
        v[generateKeyHash(ConfigHelper().primaryCacheKey + "#@#" + key)] = {
          'timestamp': DateTime.now(),
          "data": value,
        };
      },
    );

    if (isIsolate) {
      var runBackgroundTask = await getSharedPrefValue("backgroundTask");
      if (runBackgroundTask) {
        await locator<StorageService>().getBox('offline').putAll(v);
      }
    } else {
      await locator<StorageService>().getBox('offline').putAll(v);
    }
  }

  static getItem(String secondaryKey) {
    if (ConfigHelper().primaryCacheKey == null) {
      return {"data": null};
    }
    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;
    var keyHash = generateKeyHash(k);

    if (locator<StorageService>().getBox('offline').get(keyHash) == null) {
      return {"data": null};
    }

    return locator<StorageService>().getBox('offline').get(keyHash);
  }

  static Future remove(String secondaryKey) async {
    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;
    var keyHash = generateKeyHash(k);
    locator<StorageService>().getBox('offline').delete(keyHash);
  }

  static storeModule(String module, [bool isIsolate = false]) async {
    try {
      var cache = {};
      var deskSideBarItems = await locator<Api>().getDeskSideBarItems();
      var doctypes = await locator<Api>().getDesktopPage(module);
      var activeDoctypes = getActivatedDoctypes(doctypes, module);

      cache["${module}Doctypes"] = doctypes;
      cache['deskSidebarItems'] = deskSideBarItems;

      var f = <Future>[];

      for (var doctype in activeDoctypes) {
        f.add(
          storeDocListAndDoc(doctype.name),
        );
        f.add(
          storeLinkFields(doctype.name),
        );
        f.add(
          storeDoctypeMeta(doctype.name),
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
      await putAllItems(cache, isIsolate);
    } catch (e) {
      print(e);
    }
  }

  static Future<Map> storeDoctypeMeta(String doctype) async {
    var cache = {};
    try {
      var response = await locator<Api>().getDoctype(doctype);
      cache['${doctype}Meta'] = response;
    } catch (e) {
      print(e);
    }

    return cache;
  }

  static Future<Map> storeLinkFields(String doctype) async {
    var cache = {};
    try {
      var f = <Future>[];
      var linkFieldDoctypes = await getLinkFields(doctype);

      for (var doctype in linkFieldDoctypes) {
        f.add(storeLinkField(doctype));
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

  static Future<Map> storeLinkField(String doctype) async {
    var cache = {};
    try {
      var linkData = await locator<Api>().searchLink(
        doctype: doctype,
        pageLength: 9999,
      );
      cache['${doctype}LinkFull'] = linkData;
    } catch (e) {
      print(e);
    }

    return cache;
  }

  static Future<Map> storeDocListAndDoc(String doctype) async {
    var cache = {};
    var f = <Future>[];

    try {
      var docMeta = await locator<Api>().getDoctype(doctype);

      var docList = await locator<Api>().fetchList(
        doctype: doctype,
        fieldnames: generateFieldnames(doctype, docMeta.docs[0]),
        pageLength: Constants.offlinePageSize,
        offset: 0,
        meta: docMeta.docs[0],
      );

      cache['${doctype}List'] = docList;

      for (var doc in docList) {
        f.add(
          storeDoc(
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

  static Future<Map> storeDoc(String doctype, String docName) async {
    var cache = {};
    try {
      var docForm = await locator<Api>().getdoc(doctype, docName);
      cache['$doctype$docName'] = docForm;
    } catch (e) {
      print(e);
    }
    return cache;
  }

  static Future<bool> storeApiResponse() async {
    var storeApiResponse = await getSharedPrefValue(
      "storeApiResponse",
    );
    return storeApiResponse ?? true;
  }

  static Future<DoctypeResponse> getMeta(String doctype) async {
    var cachedMeta = getItem('${doctype}Meta');
    var isOnline = await verifyOnline();

    DoctypeResponse metaResponse;

    if (isOnline) {
      if (cachedMeta["data"] != null) {
        DateTime cacheTime = cachedMeta["timestamp"];
        var cacheTimeElapsedMins =
            DateTime.now().difference(cacheTime).inMinutes;
        if (cacheTimeElapsedMins > 15) {
          metaResponse = await locator<Api>().getDoctype(doctype);
        } else {
          metaResponse = DoctypeResponse.fromJson(
              Map<String, dynamic>.from(cachedMeta["data"]));
        }
      } else {
        metaResponse = await locator<Api>().getDoctype(doctype);
      }
    } else {
      if (cachedMeta["data"] != null) {
        metaResponse = DoctypeResponse.fromJson(
            Map<String, dynamic>.from(cachedMeta["data"]));
      } else {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
    }
    return metaResponse;
  }
}
