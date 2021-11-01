class NoticationResponse {
  late List<Message> message;

  NoticationResponse({required this.message});

  NoticationResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] != null) {
      message = [];
      json['message'].forEach((v) {
        message.add(new Message.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message.map((v) => v.toJson()).toList();
    return data;
  }
}

class Message {
  late String? name;
  late String? creation;
  late String? modified;
  late String? modifiedBy;
  late String? owner;
  late int? docstatus;
  late dynamic parent;
  late dynamic parentfield;
  late dynamic parenttype;
  late int? idx;
  late String? forUser;
  late String? type;
  late String? fromUser;
  late String? subject;
  late dynamic emailContent;
  late String? documentName;
  late String? documentType;
  late int? read;
  late dynamic nUserTags;
  late dynamic nComments;
  late dynamic nAssign;
  late dynamic nLikedBy;
  late dynamic nSeen;
  late dynamic attachedFile;

  Message(
      {this.name,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.owner,
      this.docstatus,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.forUser,
      this.type,
      this.fromUser,
      this.subject,
      this.emailContent,
      this.documentName,
      this.documentType,
      this.read,
      this.nUserTags,
      this.nComments,
      this.nAssign,
      this.nLikedBy,
      this.nSeen,
      this.attachedFile});

  Message.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    owner = json['owner'];
    docstatus = json['docstatus'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    forUser = json['for_user'];
    type = json['type'];
    fromUser = json['from_user'];
    subject = json['subject'];
    emailContent = json['email_content'];
    documentName = json['document_name'];
    documentType = json['document_type'];
    read = json['read'];
    nUserTags = json['_user_tags'];
    nComments = json['_comments'];
    nAssign = json['_assign'];
    nLikedBy = json['_liked_by'];
    nSeen = json['_seen'];
    attachedFile = json['attached_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['creation'] = this.creation;
    data['modified'] = this.modified;
    data['modified_by'] = this.modifiedBy;
    data['owner'] = this.owner;
    data['docstatus'] = this.docstatus;
    data['parent'] = this.parent;
    data['parentfield'] = this.parentfield;
    data['parenttype'] = this.parenttype;
    data['idx'] = this.idx;
    data['for_user'] = this.forUser;
    data['type'] = this.type;
    data['from_user'] = this.fromUser;
    data['subject'] = this.subject;
    data['email_content'] = this.emailContent;
    data['document_name'] = this.documentName;
    data['document_type'] = this.documentType;
    data['read'] = this.read;
    data['_user_tags'] = this.nUserTags;
    data['_comments'] = this.nComments;
    data['_assign'] = this.nAssign;
    data['_liked_by'] = this.nLikedBy;
    data['_seen'] = this.nSeen;
    data['attached_file'] = this.attachedFile;
    return data;
  }
}
