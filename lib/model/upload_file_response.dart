class UploadedFileResponse {
  late UploadedFile uploadedFile;

  UploadedFileResponse({required this.uploadedFile});

  UploadedFileResponse.fromJson(Map<String, dynamic> json) {
    uploadedFile = json['message'] = UploadedFile.fromJson(json['message']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.uploadedFile.toJson();
    return data;
  }
}

class UploadedFile {
  late String name;
  late String owner;
  late String creation;
  late String modified;
  late String modifiedBy;
  late int idx;
  late int docstatus;
  late String fileName;
  late int isPrivate;
  late int isHomeFolder;
  late int isAttachmentsFolder;
  late int fileSize;
  late String fileUrl;
  late String folder;
  late int isFolder;
  late String attachedToDoctype;
  late String attachedToName;
  late String contentHash;
  late int uploadedToDropbox;
  late int uploadedToGoogleDrive;
  late String doctype;

  UploadedFile({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.idx,
    required this.docstatus,
    required this.fileName,
    required this.isPrivate,
    required this.isHomeFolder,
    required this.isAttachmentsFolder,
    required this.fileSize,
    required this.fileUrl,
    required this.folder,
    required this.isFolder,
    required this.attachedToDoctype,
    required this.attachedToName,
    required this.contentHash,
    required this.uploadedToDropbox,
    required this.uploadedToGoogleDrive,
    required this.doctype,
  });

  UploadedFile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    fileName = json['file_name'];
    isPrivate = json['is_private'];
    isHomeFolder = json['is_home_folder'];
    isAttachmentsFolder = json['is_attachments_folder'];
    fileSize = json['file_size'];
    fileUrl = json['file_url'];
    folder = json['folder'];
    isFolder = json['is_folder'];
    attachedToDoctype = json['attached_to_doctype'];
    attachedToName = json['attached_to_name'];
    contentHash = json['content_hash'];
    uploadedToDropbox = json['uploaded_to_dropbox'];
    uploadedToGoogleDrive = json['uploaded_to_google_drive'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['creation'] = this.creation;
    data['modified'] = this.modified;
    data['modified_by'] = this.modifiedBy;
    data['idx'] = this.idx;
    data['docstatus'] = this.docstatus;
    data['file_name'] = this.fileName;
    data['is_private'] = this.isPrivate;
    data['is_home_folder'] = this.isHomeFolder;
    data['is_attachments_folder'] = this.isAttachmentsFolder;
    data['file_size'] = this.fileSize;
    data['file_url'] = this.fileUrl;
    data['folder'] = this.folder;
    data['is_folder'] = this.isFolder;
    data['attached_to_doctype'] = this.attachedToDoctype;
    data['attached_to_name'] = this.attachedToName;
    data['content_hash'] = this.contentHash;
    data['uploaded_to_dropbox'] = this.uploadedToDropbox;
    data['uploaded_to_google_drive'] = this.uploadedToGoogleDrive;
    data['doctype'] = this.doctype;
    return data;
  }
}
