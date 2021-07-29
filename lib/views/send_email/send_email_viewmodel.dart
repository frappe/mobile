import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/model/upload_file_response.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SendEmailViewModel extends BaseViewModel {
  bool expanded = false;
  List<DoctypeField> fields = [];
  List<Attachments> filesToAttach = [];
  Map sendSettings = {};

  toggleExpanded() {
    expanded = !expanded;
    notifyListeners();
  }

  removeAttachment(int index) {
    filesToAttach.removeAt(index);
    notifyListeners();
  }

  initFields({
    required String doctype,
    required String name,
    String? subjectField,
    String? body,
    String? to,
    String? cc,
    String? bcc,
  }) {
    fields = [
      DoctypeField(
        fieldname: "recipients",
        fieldtype: "MultiSelect",
        label: "To",
        defaultValue: to,
        reqd: 1,
      ),
      DoctypeField(
        fieldname: "cc",
        fieldtype: "MultiSelect",
        label: "CC",
        defaultValue: cc,
      ),
      DoctypeField(
        fieldname: "bcc",
        fieldtype: "MultiSelect",
        label: "BCC",
        defaultValue: bcc,
      ),
      // {
      //   "label": "Email Template",
      //   "fieldname": "email_template",
      //   "doctype": "Email Template",
      //   "fieldtype": "Link"
      // },
      DoctypeField(
        fieldname: "subject",
        fieldtype: "Small Text",
        label: "Subject",
        reqd: 1,
        defaultValue: '$subjectField (#$name)',
      ),
      DoctypeField(
        fieldtype: "Text Editor",
        fieldname: "content",
        label: "Message",
        reqd: 1,
        defaultValue: body,
      ),
      DoctypeField(
        fieldname: "send_me_a_copy",
        fieldtype: "Check",
        defaultValue: false,
        label: "Send me a copy",
      ),
      DoctypeField(
        fieldname: "send_read_receipt",
        fieldtype: "Check",
        defaultValue: false,
        label: "Send Read Receipt",
      ),
      // DoctypeField(
      //   fieldname: "attach_document_print",
      //   fieldtype: "Check",
      //   defaultValue: false,
      //   label: "Attach Document Print",
      // ),
    ];

    sendSettings = {
      fields[5].fieldname: 0,
      fields[6].fieldname: 0,
    };
  }

  addAttachments(List<Attachments> attachments) {
    filesToAttach.addAll(attachments);
    notifyListeners();
  }

  updateSendSetting({required String fieldname, dynamic value}) {
    sendSettings[fieldname] = value;
    notifyListeners();
  }
}
