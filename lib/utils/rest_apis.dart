
import 'package:dio/dio.dart';

import '../utils/response_models.dart';
import './http.dart';

Future<DioLinkFieldResponse> searchLink(data) async {
    final response = await dio.post('/method/frappe.desk.search.search_link',
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioLinkFieldResponse.fromJson(response.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<DioGetContactListResponse> getContactList(data) async {
    final response = await dio.post('/method/frappe.email.get_contact_list',
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioGetContactListResponse.fromJson(response.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
