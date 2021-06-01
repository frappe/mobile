class GetDocResponse {
  late List docs;
  Docinfo? docinfo;

  GetDocResponse({
    required this.docs,
    this.docinfo,
  });

  GetDocResponse.fromJson(Map<String, dynamic> json) {
    if (json['docs'] != null) {
      docs = [];
      json['docs'].forEach((v) {
        docs.add(v);
      });
    }
    docinfo = Docinfo.fromJson(json['docinfo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['docs'] = this.docs.map((v) => v.toJson()).toList();
    data['docinfo'] = this.docinfo?.toJson();
    return data;
  }
}

class Docinfo {
  late List<Attachments> attachments;
  late List<AttachmentLogs>? attachmentLogs;
  late List<Communication> communications;
  late List<Comment> comments;
  int? totalComments;
  late List<Version> versions;
  late List<Assignments> assignments;
  List? assignmentLogs;
  Permissions? permissions;
  late List<Shared> shared;
  late List shareLogs;
  List? likeLogs;
  late List<View> views;
  List<EnergyPointLogs>? energyPointLogs;
  List? additionalTimelineContent;
  List? milestones;
  dynamic isDocumentFollowed;
  late String tags;
  String? documentEmail;

  Docinfo({
    required this.attachments,
    this.attachmentLogs,
    required this.communications,
    required this.comments,
    this.totalComments,
    required this.versions,
    required this.assignments,
    this.assignmentLogs,
    this.permissions,
    required this.shared,
    required this.shareLogs,
    this.likeLogs,
    required this.views,
    required this.energyPointLogs,
    this.additionalTimelineContent,
    this.milestones,
    this.isDocumentFollowed,
    required this.tags,
    this.documentEmail,
  });

  Docinfo.fromJson(Map<String, dynamic> json) {
    if (json['attachments'] != null) {
      attachments = [];
      json['attachments'].forEach((v) {
        attachments.add(new Attachments.fromJson(v));
      });
    }
    if (json['attachment_logs'] != null) {
      attachmentLogs = [];
      json['attachment_logs'].forEach((v) {
        attachmentLogs?.add(new AttachmentLogs.fromJson(v));
      });
    }
    if (json['communications'] != null) {
      communications = [];
      json['communications'].forEach((v) {
        communications.add(Communication.fromJson(v));
      });
    }
    if (json['comments'] != null) {
      comments = [];
      json['comments'].forEach((v) {
        comments.add(Comment.fromJson(v));
      });
    }
    totalComments = json['total_comments'];
    if (json['versions'] != null) {
      versions = [];
      json['versions'].forEach((v) {
        versions.add(new Version.fromJson(v));
      });
    }
    if (json['assignments'] != null) {
      assignments = [];
      json['assignments'].forEach((v) {
        assignments.add(new Assignments.fromJson(v));
      });
    }
    if (json['assignment_logs'] != null) {
      assignmentLogs = [];
      json['assignment_logs'].forEach((v) {
        assignmentLogs?.add(v);
      });
    }
    permissions = json['permissions'] != null
        ? new Permissions.fromJson(json['permissions'])
        : null;
    if (json['shared'] != null) {
      shared = [];
      json['shared'].forEach((v) {
        shared.add(new Shared.fromJson(v));
      });
    }
    if (json['share_logs'] != null) {
      shareLogs = [];
      json['share_logs'].forEach((v) {
        shareLogs.add(v);
      });
    }
    if (json['like_logs'] != null) {
      likeLogs = [];
      json['like_logs'].forEach((v) {
        likeLogs?.add(v);
      });
    }
    if (json['views'] != null) {
      views = [];
      json['views'].forEach((v) {
        views.add(View.fromJson(v));
      });
    }
    if (json['energy_point_logs'] != null) {
      energyPointLogs = [];
      json['energy_point_logs'].forEach((v) {
        energyPointLogs?.add(new EnergyPointLogs.fromJson(v));
      });
    }
    if (json['additional_timeline_content'] != null) {
      additionalTimelineContent = [];
      json['additional_timeline_content'].forEach((v) {
        additionalTimelineContent?.add(v);
      });
    }
    if (json['milestones'] != null) {
      milestones = [];
      json['milestones'].forEach((v) {
        milestones?.add(v);
      });
    }
    isDocumentFollowed = json['is_document_followed'];
    tags = json['tags'];
    documentEmail = json['document_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attachments'] = this.attachments.map((v) => v.toJson()).toList();
    if (this.attachmentLogs != null) {
      data['attachment_logs'] =
          this.attachmentLogs?.map((v) => v.toJson()).toList();
    }
    data['communications'] =
        this.communications.map((v) => v.toJson()).toList();
    data['comments'] = this.comments.map((v) => v.toJson()).toList();
    data['total_comments'] = this.totalComments;
    data['versions'] = this.versions.map((v) => v.toJson()).toList();
    data['assignments'] = this.assignments.map((v) => v.toJson()).toList();
    if (this.assignmentLogs != null) {
      data['assignment_logs'] =
          this.assignmentLogs?.map((v) => v.toJson()).toList();
    }
    if (this.permissions != null) {
      data['permissions'] = this.permissions?.toJson();
    }
    data['shared'] = this.shared.map((v) => v.toJson()).toList();
    data['share_logs'] = this.shareLogs.map((v) => v.toJson()).toList();
    if (this.likeLogs != null) {
      data['like_logs'] = this.likeLogs?.map((v) => v).toList();
    }
    data['views'] = this.views.map((v) => v.toJson()).toList();
    data['energy_point_logs'] =
        this.energyPointLogs?.map((v) => v.toJson()).toList();
    if (this.additionalTimelineContent != null) {
      data['additional_timeline_content'] =
          this.additionalTimelineContent?.map((v) => v).toList();
    }
    if (this.milestones != null) {
      data['milestones'] = this.milestones?.map((v) => v).toList();
    }
    data['is_document_followed'] = this.isDocumentFollowed;
    data['tags'] = this.tags;
    data['document_email'] = this.documentEmail;
    return data;
  }
}

class Attachments {
  late String name;
  late String fileName;
  late String fileUrl;
  late int isPrivate;

  Attachments({
    required this.name,
    required this.fileName,
    required this.fileUrl,
    required this.isPrivate,
  });

  Attachments.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fileName = json['file_name'];
    fileUrl = json['file_url'];
    isPrivate = json['is_private'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['file_name'] = this.fileName;
    data['file_url'] = this.fileUrl;
    data['is_private'] = this.isPrivate;
    return data;
  }
}

class AttachmentLogs {
  late String name;
  late String creation;
  late String content;
  late String owner;
  late String commentType;

  AttachmentLogs({
    required this.name,
    required this.creation,
    required this.content,
    required this.owner,
    required this.commentType,
  });

  AttachmentLogs.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    creation = json['creation'];
    content = json['content'];
    owner = json['owner'];
    commentType = json['comment_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['creation'] = this.creation;
    data['content'] = this.content;
    data['owner'] = this.owner;
    data['comment_type'] = this.commentType;
    return data;
  }
}

class Communication {
  late String name;
  late String communicationType;
  late String communicationMedium;
  late String commentType;
  late String communicationDate;
  late String content;
  late String sender;
  late String senderFullName;
  late dynamic cc;
  late dynamic bcc;
  late String creation;
  late String subject;
  late String deliveryStatus;
  late String sLikedBy;
  late String referenceDoctype;
  late String referenceName;
  late int readByRecipient;
  late int rating;
  late String attachments;

  Communication({
    required this.name,
    required this.communicationType,
    required this.communicationMedium,
    required this.commentType,
    required this.communicationDate,
    required this.content,
    required this.sender,
    required this.senderFullName,
    required this.cc,
    required this.bcc,
    required this.creation,
    required this.subject,
    required this.deliveryStatus,
    required this.sLikedBy,
    required this.referenceDoctype,
    required this.referenceName,
    required this.readByRecipient,
    required this.rating,
    required this.attachments,
  });

  Communication.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    communicationType = json['communication_type'];
    communicationMedium = json['communication_medium'];
    commentType = json['comment_type'];
    communicationDate = json['communication_date'];
    content = json['content'];
    sender = json['sender'];
    senderFullName = json['sender_full_name'];
    cc = json['cc'];
    bcc = json['bcc'];
    creation = json['creation'];
    subject = json['subject'];
    deliveryStatus = json['delivery_status'];
    sLikedBy = json['_liked_by'];
    referenceDoctype = json['reference_doctype'];
    referenceName = json['reference_name'];
    readByRecipient = json['read_by_recipient'];
    rating = json['rating'];
    attachments = json['attachments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['communication_type'] = this.communicationType;
    data['communication_medium'] = this.communicationMedium;
    data['comment_type'] = this.commentType;
    data['communication_date'] = this.communicationDate;
    data['content'] = this.content;
    data['sender'] = this.sender;
    data['sender_full_name'] = this.senderFullName;
    data['cc'] = this.cc;
    data['bcc'] = this.bcc;
    data['creation'] = this.creation;
    data['subject'] = this.subject;
    data['delivery_status'] = this.deliveryStatus;
    data['_liked_by'] = this.sLikedBy;
    data['reference_doctype'] = this.referenceDoctype;
    data['reference_name'] = this.referenceName;
    data['read_by_recipient'] = this.readByRecipient;
    data['rating'] = this.rating;
    data['attachments'] = this.attachments;
    return data;
  }
}

class Comment {
  late String name;
  late String creation;
  late String content;
  late String owner;
  late String commentType;

  Comment({
    required this.name,
    required this.creation,
    required this.content,
    required this.owner,
    required this.commentType,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    creation = json['creation'];
    content = json['content'];
    owner = json['owner'];
    commentType = json['comment_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['creation'] = this.creation;
    data['content'] = this.content;
    data['owner'] = this.owner;
    data['comment_type'] = this.commentType;
    return data;
  }
}

class Version {
  late String name;
  late String owner;
  late String creation;
  late String data;

  Version({
    required this.name,
    required this.owner,
    required this.creation,
    required this.data,
  });

  Version.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['creation'] = this.creation;
    data['data'] = this.data;
    return data;
  }
}

class View {
  late String name;
  late String creation;
  late String owner;

  View({
    required this.name,
    required this.creation,
    required this.owner,
  });

  View.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    creation = json['creation'];
    owner = json['owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['creation'] = this.creation;
    data['owner'] = this.owner;
    return data;
  }
}

class Assignments {
  late String name;
  late String owner;
  late String description;
  late String status;

  Assignments({
    required this.name,
    required this.owner,
    required this.description,
    required this.status,
  });

  Assignments.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    description = json['description'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['description'] = this.description;
    data['status'] = this.status;
    return data;
  }
}

class Permissions {
  int? select;
  int? read;
  int? write;
  int? create;
  int? delete;
  int? submit;
  int? cancel;
  int? amend;
  int? print;
  int? email;
  int? report;
  int? import;
  int? export;
  int? setUserPermissions;
  int? share;

  Permissions(
      {this.select,
      this.read,
      this.write,
      this.create,
      this.delete,
      this.submit,
      this.cancel,
      this.amend,
      this.print,
      this.email,
      this.report,
      this.import,
      this.export,
      this.setUserPermissions,
      this.share});

  Permissions.fromJson(Map<String, dynamic> json) {
    select = json['select'];
    read = json['read'];
    write = json['write'];
    create = json['create'];
    delete = json['delete'];
    submit = json['submit'];
    cancel = json['cancel'];
    amend = json['amend'];
    print = json['print'];
    email = json['email'];
    report = json['report'];
    import = json['import'];
    export = json['export'];
    setUserPermissions = json['set_user_permissions'];
    share = json['share'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['select'] = this.select;
    data['read'] = this.read;
    data['write'] = this.write;
    data['create'] = this.create;
    data['delete'] = this.delete;
    data['submit'] = this.submit;
    data['cancel'] = this.cancel;
    data['amend'] = this.amend;
    data['print'] = this.print;
    data['email'] = this.email;
    data['report'] = this.report;
    data['import'] = this.import;
    data['export'] = this.export;
    data['set_user_permissions'] = this.setUserPermissions;
    data['share'] = this.share;
    return data;
  }
}

class Shared {
  String? name;
  String? user;
  int? read;
  int? write;
  int? share;
  int? everyone;
  String? owner;
  String? creation;

  Shared(
      {this.name,
      this.user,
      this.read,
      this.write,
      this.share,
      this.everyone,
      this.owner,
      this.creation});

  Shared.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    user = json['user'];
    read = json['read'];
    write = json['write'];
    share = json['share'];
    everyone = json['everyone'];
    owner = json['owner'];
    creation = json['creation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['user'] = this.user;
    data['read'] = this.read;
    data['write'] = this.write;
    data['share'] = this.share;
    data['everyone'] = this.everyone;
    data['owner'] = this.owner;
    data['creation'] = this.creation;
    return data;
  }
}

class EnergyPointLogs {
  late String name;
  late String creation;
  late String modified;
  late String modifiedBy;
  late String owner;
  late int docstatus;
  late dynamic parent;
  late dynamic parentfield;
  late dynamic parenttype;
  late int idx;
  late String user;
  late String type;
  late int points;
  late String rule;
  late String referenceDoctype;
  late String referenceName;
  late int reverted;
  late dynamic revertOf;
  late String reason;
  late int seen;
  late dynamic nUserTags;
  late dynamic nComments;
  late dynamic nAssign;
  late dynamic nLikedBy;

  EnergyPointLogs({
    required this.name,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.owner,
    required this.docstatus,
    required this.parent,
    required this.parentfield,
    required this.parenttype,
    required this.idx,
    required this.user,
    required this.type,
    required this.points,
    required this.rule,
    required this.referenceDoctype,
    required this.referenceName,
    required this.reverted,
    required this.revertOf,
    required this.reason,
    required this.seen,
    required this.nUserTags,
    required this.nComments,
    required this.nAssign,
    required this.nLikedBy,
  });

  EnergyPointLogs.fromJson(Map<String, dynamic> json) {
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
    user = json['user'];
    type = json['type'];
    points = json['points'];
    rule = json['rule'];
    referenceDoctype = json['reference_doctype'];
    referenceName = json['reference_name'];
    reverted = json['reverted'];
    revertOf = json['revert_of'];
    reason = json['reason'];
    seen = json['seen'];
    nUserTags = json['_user_tags'];
    nComments = json['_comments'];
    nAssign = json['_assign'];
    nLikedBy = json['_liked_by'];
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
    data['user'] = this.user;
    data['type'] = this.type;
    data['points'] = this.points;
    data['rule'] = this.rule;
    data['reference_doctype'] = this.referenceDoctype;
    data['reference_name'] = this.referenceName;
    data['reverted'] = this.reverted;
    data['revert_of'] = this.revertOf;
    data['reason'] = this.reason;
    data['seen'] = this.seen;
    data['_user_tags'] = this.nUserTags;
    data['_comments'] = this.nComments;
    data['_assign'] = this.nAssign;
    data['_liked_by'] = this.nLikedBy;
    return data;
  }
}
