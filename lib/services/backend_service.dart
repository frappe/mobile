import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../utils/dio_helper.dart';

import '../utils/cache_helper.dart';
import '../utils/helpers.dart';

@lazySingleton
class BackendService {
  static Future getdoc(doctype, name) async {
    var queryParams = {
      'doctype': doctype,
      'name': name,
    };

    try {
      final response = await DioHelper.dio.get(
        '/method/frappe.desk.form.load.getdoc',
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) {
            return status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        if (await CacheHelper.shouldCacheApi()) {
          await CacheHelper.putCache('$doctype$name', response.data);
        }
        return response.data;
      } else if (response.statusCode == 403) {
        throw response;
      } else {
        throw Response(statusMessage: 'Something went wrong');
      }
    } catch (e) {
      if (e is DioError) {
        var error = e.error;
        if (error is SocketException) {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
            statusMessage: error.message,
          );
        } else {
          throw Response(statusMessage: error.message);
        }
      } else {
        throw e;
      }
    }
  }

  static updateDoc(String doctype, String name, Map updateObj) async {
    var response = await DioHelper.dio.put(
      '/resource/$doctype/$name',
      data: updateObj,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 403) {
      throw response;
    } else {
      throw Response(statusMessage: 'Something went wrong');
    }
  }

  static Future<List> fetchList({
    @required List fieldnames,
    @required String doctype,
    List filters,
    pageLength,
    offset,
    @required Map meta,
  }) async {
    var queryParams = {
      'doctype': doctype,
      'fields': jsonEncode(fieldnames),
      'page_length': pageLength,
      'with_comment_count': true
    };

    queryParams['limit_start'] = offset.toString();

    if (filters != null && filters.length != 0) {
      queryParams['filters'] = jsonEncode(filters);
    }

    try {
      final response = await DioHelper.dio.get(
        '/method/frappe.desk.reportview.get',
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) {
            return status < 500;
          },
        ),
      );
      if (response.statusCode == HttpStatus.ok) {
        var l = response.data["message"];
        var newL = [];

        if (l.length == 0) {
          return newL;
        }

        for (int i = 0; i < l["values"].length; i++) {
          var o = {};
          for (int j = 0; j < l["keys"].length; j++) {
            var key = l["keys"][j];
            var value = l["values"][i][j];

            // if (key == "docstatus") {
            //   key = "status";
            //   if (isSubmittable(meta)) {
            //     if (value == 0) {
            //       value = "Draft";
            //     } else if (value == 1) {
            //       value = "Submitted";
            //     } else if (value == 2) {
            //       value = "Cancelled";
            //     }
            //   } else {
            //     value = value == 0 ? "Enabled" : "Disabled";
            //   }
            // }
            o[key] = value;
          }
          newL.add(o);
        }

        if (await CacheHelper.shouldCacheApi()) {
          await CacheHelper.putCache('${doctype}List', newL);
        }

        return newL;
      } else if (response.statusCode == HttpStatus.forbidden) {
        throw response;
      } else {
        throw Response(statusMessage: 'Something went wrong');
      }
    } catch (e) {
      if (e is DioError) {
        var error = e.error;
        if (error is SocketException) {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
            statusMessage: error.message,
          );
        } else {
          throw Response(statusMessage: error.message);
        }
      } else {
        throw e;
      }
    }
  }

  static Future postComment(refDocType, refName, content, email) async {
    var queryParams = {
      'reference_doctype': refDocType,
      'reference_name': refName,
      'content': content,
      'comment_email': email,
      'comment_by': email
    };

    final response = await DioHelper.dio.post(
        '/method/frappe.desk.form.utils.add_comment',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future getDesktopPage(module) async {
    try {
      final response = await DioHelper.dio.post(
        '/method/frappe.desk.desktop.get_desktop_page',
        data: {
          'page': module,
        },
        options: Options(
          validateStatus: (status) {
            return status < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        if (await CacheHelper.shouldCacheApi()) {
          await CacheHelper.putCache('${module}Doctypes', response.data);
        }

        return response.data;
      } else if (response.statusCode == 403) {
        throw response;
      } else {
        throw Response(statusMessage: 'Something went wrong');
      }
    } catch (e) {
      if (e is DioError) {
        var error = e.error;
        if (error is SocketException) {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
            statusMessage: error.message,
          );
        } else {
          throw Response(statusMessage: error.message);
        }
      } else {
        throw e;
      }
    }
  }

  static Future sendEmail(
      {@required recipients,
      cc,
      bcc,
      @required subject,
      @required content,
      @required doctype,
      @required doctypeName,
      sendEmail,
      printHtml,
      sendMeACopy,
      printFormat,
      emailTemplate,
      attachments,
      readReceipt,
      printLetterhead}) async {
    var queryParams = {
      'recipients': recipients,
      'subject': subject,
      'content': content,
      'doctype': doctype,
      'name': doctypeName,
      'send_email': 1
    };

    final response = await DioHelper.dio.post(
        '/method/frappe.core.doctype.communication.email.make',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future login(usr, pwd) async {
    final response = await DioHelper.dio.post(
      '/method/login',
      data: {
        'usr': usr,
        'pwd': pwd,
      },
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );
    return response;
  }

  static Future getDeskSideBarItems() async {
    try {
      final response = await DioHelper.dio.post(
        '/method/frappe.desk.desktop.get_desk_sidebar_items',
        options: Options(
          validateStatus: (status) {
            return status < 500;
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        if (await CacheHelper.shouldCacheApi()) {
          await CacheHelper.putCache('deskSidebarItems', response.data);
        }

        return response.data;
      } else if (response.statusCode == HttpStatus.forbidden) {
        throw response;
      } else {
        throw Response(statusMessage: 'Something went wrong');
      }
    } catch (e) {
      if (e is DioError) {
        var error = e.error;
        if (error is SocketException) {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
            statusMessage: error.message,
          );
        } else {
          throw Response(statusMessage: error.message);
        }
      } else {
        throw e;
      }
    }
  }

  static getDoctype(doctype) async {
    var queryParams = {'doctype': doctype};

    try {
      final response = await DioHelper.dio.get(
        '/method/frappe.desk.form.load.getdoctype',
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) {
            return status < 500;
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        List metaFields = response.data["docs"][0]["fields"];

        metaFields.forEach((field) {
          response.data["docs"][0]["_field${field["fieldname"]}"] = true;
        });
        if (await CacheHelper.shouldCacheApi()) {
          await CacheHelper.putCache('${doctype}Meta', response.data);
        }
        return response.data;
      } else if (response.statusCode == HttpStatus.forbidden) {
        throw response;
      } else {
        throw Response(statusMessage: 'Something went wrong');
      }
    } catch (e) {
      if (e is DioError) {
        var error = e.error;
        if (error is SocketException) {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
            statusMessage: error.message,
          );
        } else {
          throw Response(statusMessage: error.message);
        }
      } else {
        throw e;
      }
    }
  }

  static void addAssignees(String doctype, String name, List assignees) async {
    var data = {
      'assign_to': json.encode(assignees),
      'assign_to_me': 0,
      'doctype': doctype,
      'name': name,
      'bulk_assign': false,
      're_assign': false
    };

    var response = await DioHelper.dio.post(
      '/method/frappe.desk.form.assign_to.add',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static removeAssignee(String doctype, String name, String assignTo) async {
    var data = {
      'doctype': doctype,
      'name': name,
      'assign_to': assignTo,
    };

    var response = await DioHelper.dio.post(
      '/method/frappe.desk.form.assign_to.remove',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future getDocinfo(String doctype, String name) async {
    var data = {
      "doctype": doctype,
      "name": name,
    };

    var response = await DioHelper.dio.post(
      '/method/frappe.desk.form.load.get_docinfo',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static void removeAttachment(
    String doctype,
    String name,
    String attachmentName,
  ) async {
    var data = {
      "fid": attachmentName,
      "dt": doctype,
      "dn": name,
    };

    var response = await DioHelper.dio.post(
      '/method/frappe.desk.form.utils.remove_attach',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future deleteComment(name) async {
    var queryParams = {
      'doctype': 'Comment',
      'name': name,
    };

    final response = await DioHelper.dio.post('/method/frappe.client.delete',
        data: queryParams,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ));
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future uploadFile(
      String doctype, String name, List<File> files) async {
    for (File file in files) {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "docname": name,
        "doctype": doctype,
        "is_private": 1,
        "folder": "Home/Attachments"
      });

      var response =
          await DioHelper.dio.post("/method/upload_file", data: formData);
      if (response.statusCode != 200) {
        throw Exception('Something went wrong');
      }
    }
  }

  static Future saveDocs(doctype, formValue) async {
    var data = {
      "doctype": doctype,
      ...formValue,
    };

    try {
      final response = await DioHelper.dio.post(
        '/method/frappe.desk.form.save.savedocs',
        data: "doc=${Uri.encodeComponent(json.encode(data))}&action=Save",
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Response(statusMessage: 'Something went wrong');
      }
    } catch (e) {
      if (e is DioError) {
        var error;
        if (e.response != null) {
          error = e.response;
        } else {
          error = e.error;
        }

        if (error is SocketException) {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
            statusMessage: error.message,
          );
        } else {
          throw Response(
            statusCode: error.statusCode,
            statusMessage: error.statusMessage,
          );
        }
      } else {
        throw e;
      }
    }
  }

  static Future<Map> searchLink({
    String doctype,
    String refDoctype,
    String txt,
    int pageLength,
  }) async {
    var queryParams = {
      'txt': txt,
      'doctype': doctype,
      'reference_doctype': refDoctype,
      'ignore_user_permissions': 0,
    };

    if (pageLength != null) {
      queryParams['page_length'] = pageLength;
    }

    try {
      final response = await DioHelper.dio.post(
        '/method/frappe.desk.search.search_link',
        data: queryParams,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) {
            return status < 500;
          },
        ),
      );
      if (response.statusCode == 200) {
        if (await CacheHelper.shouldCacheApi()) {
          if (pageLength != null && pageLength == 9999) {
            await CacheHelper.putCache('${doctype}LinkFull', response.data);
          } else {
            await CacheHelper.putCache('$txt${doctype}Link', response.data);
          }
        }
        return response.data;
      } else if (response.statusCode == HttpStatus.forbidden) {
        throw response;
      } else {
        throw Response(statusMessage: 'Something went wrong');
      }
    } catch (e) {
      if (e is DioError) {
        var error = e.error;
        if (error is SocketException) {
          throw Response(
            statusCode: HttpStatus.serviceUnavailable,
            statusMessage: error.message,
          );
        } else {
          throw Response(statusMessage: error.message);
        }
      } else {
        throw e;
      }
    }
  }

  static Future<Map> getContactList(query) async {
    var data = {
      "txt": query,
    };

    final response = await DioHelper.dio.post(
        '/method/frappe.email.get_contact_list',
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future toggleLike(String doctype, String name, bool isFav) async {
    var data = {
      'doctype': doctype,
      'name': name,
      'add': isFav ? 'Yes' : 'No',
    };

    final response = await DioHelper.dio.post(
      '/method/frappe.desk.like.toggle_like',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future getTags(String doctype, String txt) async {
    var data = {
      'doctype': doctype,
      'txt': txt,
    };

    final response = await DioHelper.dio.post(
      '/method/frappe.desk.doctype.tag.tag.get_tags',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future removeTag(String doctype, String name, String tag) async {
    var data = {
      'dt': doctype,
      'dn': name,
      'tag': tag,
    };

    final response = await DioHelper.dio.post(
      '/method/frappe.desk.doctype.tag.tag.remove_tag',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future addTag(String doctype, String name, String tag) async {
    var data = {
      'dt': doctype,
      'dn': name,
      'tag': tag,
    };

    final response = await DioHelper.dio.post(
      '/method/frappe.desk.doctype.tag.tag.add_tag',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future addReview(String doctype, String name, Map reviewData) async {
    var doc = {
      "doctype": doctype,
      "name": name,
    };

    var data = '''doc=${Uri.encodeComponent(json.encode(doc))}
              &to_user=${Uri.encodeComponent(reviewData["to_user"])}
              &points=${int.parse(reviewData["points"])}
              &review_type=${reviewData["review_type"]}
              &reason=${reviewData["reason"]}'''
        .replaceAll(new RegExp(r"\s+"), "");
    // trim all whitespace

    final response = await DioHelper.dio.post(
      '/method/frappe.social.doctype.energy_point_log.energy_point_log.review',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future setPermission(
      String doctype, String name, Map shareInfo) async {
    var data = {
      'doctype': doctype,
      'name': name,
      ...shareInfo,
    };

    final response = await DioHelper.dio.post(
      '/method/frappe.share.set_permission',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future shareAdd(String doctype, String name, Map shareInfo) async {
    var data = {
      'doctype': doctype,
      'name': name,
      ...shareInfo,
    };

    final response = await DioHelper.dio.post(
      '/method/frappe.share.add',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Something went wrong');
    }
  }
}
