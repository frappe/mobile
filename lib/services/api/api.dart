import 'package:flutter/foundation.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/model/get_versions_response.dart';
import 'package:frappe_app/model/group_by_count_response.dart';
import 'package:frappe_app/model/login_request.dart';
import 'package:frappe_app/model/system_settings_response.dart';
import 'package:frappe_app/model/upload_file_response.dart';

import '../../model/doctype_response.dart';
import '../../model/desktop_page_response.dart';
import '../../model/desk_sidebar_items_response.dart';
import '../../model/login_response.dart';

abstract class Api {
  Future<LoginResponse> login(
    LoginRequest loginRequest,
  );

  Future<DeskSidebarItemsResponse> getDeskSideBarItems();

  Future<DesktopPageResponse> getDesktopPage(
    String module,
  );

  Future<DoctypeResponse> getDoctype(
    String doctype,
  );

  Future<List> fetchList({
    @required List fieldnames,
    @required String doctype,
    @required DoctypeDoc meta,
    @required String orderBy,
    List filters,
    int pageLength,
    int offset,
  });

  Future<GetDocResponse> getdoc(String doctype, String name);

  Future postComment(
    String refDocType,
    String refName,
    String content,
    String email,
  );

  Future sendEmail({
    @required recipients,
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
    printLetterhead,
  });

  Future addAssignees(String doctype, String name, List assignees);

  Future removeAssignee(String doctype, String name, String assignTo);

  Future getDocinfo(String doctype, String name);

  Future removeAttachment(
    String doctype,
    String name,
    String attachmentName,
  );

  Future deleteComment(String name);

  Future<List<UploadedFile>> uploadFiles({
    @required String doctype,
    @required String name,
    @required List<FrappeFile> files,
  });

  Future saveDocs(String doctype, Map formValue);

  Future<Map> searchLink({
    String doctype,
    String refDoctype,
    String txt,
    int pageLength,
  });

  Future toggleLike(String doctype, String name, bool isFav);

  Future getTags(String doctype, String txt);

  Future removeTag(String doctype, String name, String tag);

  Future addTag(String doctype, String name, String tag);

  Future addReview(String doctype, String name, Map reviewData);

  Future setPermission({
    @required String doctype,
    @required String name,
    @required Map shareInfo,
    @required String user,
  });

  Future shareAdd(String doctype, String name, Map shareInfo);

  Future shareGetUsers({
    @required String doctype,
    @required String name,
  });

  Future<Map> getContactList(String query);

  Future<GroupByCountResponse> getGroupByCount({
    required String doctype,
    required List currentFilters,
    required String field,
  });

  Future<int> getReportViewCount({
    required String doctype,
    required Map filters,
    required List<DoctypeField> fields,
  });

  Future<SystemSettingsResponse> getSystemSettings();

  Future<GetVersionsResponse> getVersions();

  Future<List> getList({
    required List fields,
    required int limit,
    required String orderBy,
    required String doctype,
  });
}
