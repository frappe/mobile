import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'helpers.dart';
import 'http.dart';

class BackendService {
  final BuildContext context;

  BackendService(
    this.context,
  );

  Future getdoc(doctype, name) async {
    var queryParams = {
      'doctype': doctype,
      'name': name,
    };

    final response = await dio.get(
      '/method/frappe.desk.form.load.getdoc',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  updateDoc(String doctype, String name, Map updateObj) async {
    var response = await dio.put(
      '/resource/$doctype/$name',
      data: updateObj,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 403) {
      logout(context);
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

    final response = await dio.get(
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
      for (int i = 0; i < l["values"].length; i++) {
        newL.add([l["keys"], l["values"][i]]);
      }

      return newL;
    } else if (response.statusCode == 403) {
      logout(context);
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

    final response = await dio.post(
        '/method/frappe.desk.form.utils.add_comment',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future getDesktopPage(module, context) async {
    final response = await dio.post(
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
      return response.data;
    } else if (response.statusCode == 403) {
      logout(context);
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

    final response = await dio.post(
        '/method/frappe.core.doctype.communication.email.make',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future login(usr, pwd) async {
    final response = await dio.post(
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

  Future getDeskSideBarItems(context) async {
    final response = await dio.post(
      '/method/frappe.desk.desktop.get_desk_sidebar_items',
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  getDoctype(doctype) async {
    var queryParams = {'doctype': doctype};

    final response = await dio.get(
      '/method/frappe.desk.form.load.getdoctype',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 403) {
      logout(context);
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

    var response = await dio.post(
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

    var response = await dio.post(
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

    var response = await dio.post(
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

    var response = await dio.post(
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

    final response = await dio.post('/method/frappe.client.delete',
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

      var response = await dio.post("/method/upload_file", data: formData);
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

    final response = await dio.post(
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

  Future<Map> searchLink(String doctype, String refDoctype, String txt) async {
    var queryParams = {
      'txt': txt,
      'doctype': doctype,
      'reference_doctype': refDoctype,
      'ignore_user_permissions': 0
    };

    final response = await dio.post('/method/frappe.desk.search.search_link',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<Map> getContactList(query) async {
    var data = {
      "txt": query,
    };

    final response = await dio.post('/method/frappe.email.get_contact_list',
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load album');
    }
  }
}
