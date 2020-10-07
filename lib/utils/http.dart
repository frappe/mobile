import 'package:frappe_app/utils/dio_helper.dart';

import '../utils/cache_helper.dart';
import '../utils/config_helper.dart';
import '../utils/backend_service.dart';

void initConfig() async {
  if (ConfigHelper().baseUrl != null) {
    await DioHelper.init(ConfigHelper().baseUrl);
  }
}

void cacheAllUsers() async {
  if (CacheHelper.getCache('allUsers')["data"] != null) {
    return;
  } else {
    var fieldNames = [
      "`tabUser`.`name`",
      "`tabUser`.`full_name`",
      "`tabUser`.`user_image`",
    ];

    var filters = [
      ["User", "enabled", "=", 1]
    ];

    var meta = await BackendService.getDoctype('User');

    var res = await BackendService.fetchList(
      fieldnames: fieldNames,
      doctype: 'User',
      filters: filters,
      meta: meta,
    );

    var usr = {};
    res.forEach((element) {
      usr[element["name"]] = element;
    });
    CacheHelper.putCache('allUsers', usr);
  }
}

void setBaseUrl(url) async {
  if (!url.startsWith('https://')) {
    url = "https://$url";
  }
  await ConfigHelper.set('baseUrl', url);
  await DioHelper.init(url);
}

String getAbsoluteUrl(String url) {
  return Uri.encodeFull("${ConfigHelper().baseUrl}$url");
}
