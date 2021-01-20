import 'package:frappe_app/utils/cache_helper.dart';

class FilterListViewModel {
  getData(String doctype) async {
    var meta = await CacheHelper.getMeta(doctype);
    var cachedFilter = CacheHelper.getCache('${doctype}Filter');
    List filter = cachedFilter["data"] ?? [];

    return {
      "meta": meta,
      "filter": filter,
    };
  }
}
