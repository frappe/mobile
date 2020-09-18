import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utils/dio_helper.dart';

import 'helpers.dart';

class BackendService {
  final Map meta;

  BackendService({
    this.meta,
  });

  Future getdoc(doctype, name) async {
    var queryParams = {
      'doctype': doctype,
      'name': name,
    };

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
      putCache('$doctype$name', response.data);
      return response.data;
    } else if (response.statusCode == 403) {
      logout();
    } else {
      throw Exception('Failed to load album');
    }
  }

  updateDoc(String doctype, String name, Map updateObj) async {
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
      logout();
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List> fetchList({
    @required List fieldnames,
    @required String doctype,
    List filters,
    pageLength,
    offset,
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

    final response = await DioHelper.dio.get(
      '/method/frappe.desk.reportview.get',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );
    if (response.statusCode == 200) {
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

          if (key == "docstatus") {
            key = "status";
            if (isSubmittable(meta)) {
              if (value == 0) {
                value = "Draft";
              } else if (value == 1) {
                value = "Submitted";
              } else if (value == 2) {
                value = "Cancelled";
              }
            } else {
              value = value == 0 ? "Enabled" : "Disabled";
            }
          }
          o[key] = value;
        }
        newL.add(o);
      }

      putCache('${doctype}List', newL);

      return newL;
    } else if (response.statusCode == 403) {
      logout();
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future postComment(refDocType, refName, content, email) async {
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
      throw Exception('Failed to load album');
    }
  }

  Future getDesktopPage(module) async {
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
      putCache('${module}Doctypes', response.data);
      return response.data;
    } else if (response.statusCode == 403) {
      logout();
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future sendEmail(
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
      throw Exception('Failed to load album');
    }
  }

  Future login(usr, pwd) async {
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

  Future getDeskSideBarItems() async {
    final response = await DioHelper.dio.post(
      '/method/frappe.desk.desktop.get_desk_sidebar_items',
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      putCache('deskSidebarItems', response.data);
      return response.data;
    } else if (response.statusCode == 403) {
      logout();
    } else {
      throw Exception('Failed to load album');
    }
  }

  getDoctype(doctype) async {
    var queryParams = {'doctype': doctype};

    final response = await DioHelper.dio.get(
      '/method/frappe.desk.form.load.getdoctype',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      putCache('${doctype}Meta', response.data);
      return response.data;
    } else if (response.statusCode == 403) {
      logout();
    } else {
      throw Exception('Failed to load album');
    }
  }

  void addAssignees(String doctype, String name, List assignees) async {
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
      throw Exception('Failed to load album');
    }
  }

  removeAssignee(String doctype, String name, String assignTo) async {
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
      throw Exception('Failed to load album');
    }
  }

  Future getDocinfo(String doctype, String name) async {
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
      throw Exception('Failed to load album');
    }
  }

  void removeAttachment(
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
      throw Exception('Failed to load album');
    }
  }

  Future deleteComment(name) async {
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
      throw Exception('Failed to load album');
    }
  }

  Future uploadFile(String doctype, String name, List<File> files) async {
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
        throw Exception('Failed to load album');
      }
    }
  }

  Future saveDocs(doctype, formValue) async {
    var data = {
      "doctype": doctype,
      ...formValue,
    };

    final response = await DioHelper.dio.post(
      '/method/frappe.desk.form.save.savedocs',
      data: "doc=${Uri.encodeFull(json.encode(data))}&action=Save",
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<Map> searchLink({
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

    final response = await DioHelper.dio.post(
        '/method/frappe.desk.search.search_link',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
      if (pageLength != null && pageLength == 9999) {
        putCache('${doctype}LinkFull', response.data);
      } else {
        putCache('$txt${doctype}Link', response.data);
      }
      return response.data;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<Map> getContactList(query) async {
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
      throw Exception('Failed to load album');
    }
  }

  Future toggleLike(String doctype, String name, bool isFav) async {
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

  Future getTags(String doctype, String txt) async {
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

  Future removeTag(String doctype, String name, String tag) async {
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

  Future addTag(String doctype, String name, String tag) async {
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

  Future addReview(String doctype, String name, Map reviewData) async {
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

  Future setPermission(String doctype, String name, Map shareInfo) async {
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

  Future shareAdd(String doctype, String name, Map shareInfo) async {
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
