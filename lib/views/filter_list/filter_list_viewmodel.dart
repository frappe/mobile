import 'package:frappe_app/utils/cache_helper.dart';

class FilterListViewModel {
  getData(String doctype) async {
    var meta = await CacheHelper.getMeta(doctype);

    return {
      "meta": meta,
    };
  }
}
