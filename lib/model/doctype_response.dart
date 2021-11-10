class DoctypeResponse {
  late List<DoctypeDoc> docs;
  late String userSettings;

  DoctypeResponse({required this.docs, required this.userSettings});

  DoctypeResponse.fromJson(Map<dynamic, dynamic> json) {
    if (json['docs'] != null) {
      docs = [];
      json['docs'].forEach((v) {
        docs.add(new DoctypeDoc.fromJson(Map<dynamic, dynamic>.from(v)));
      });
    }
    userSettings = json['user_settings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['docs'] = this.docs.map((v) => v.toJson()).toList();
    data['user_settings'] = this.userSettings;
    return data;
  }
}

class DoctypeDoc {
  late String? doctype;
  late String name;
  late String? owner;
  late String? creation;
  late String? modified;
  late String? modifiedBy;
  late int? idx;
  late int? docstatus;
  late String? searchFields;
  late int issingle;
  late int? istable;
  late int? editableGrid;
  late int? trackChanges;
  late String module;
  late String? autoname;
  late String? nameCase;
  late String? titleField;
  late String? subjectField;
  late String? senderField;
  late String? imageField;
  late String? sortField;
  late String? sortOrder;
  late String? description;
  late int? readOnly;
  late int? inCreate;
  late int? allowCopy;
  late int? allowRename;
  late int? allowImport;
  late int? hideToolbar;
  late int? trackSeen;
  late int? maxAttachments;
  late String? documentType;
  late String? icon;
  late String? engine;
  late int? isSubmittable;
  late int? showNameInGlobalSearch;
  late int? custom;
  late int? beta;
  late int? hasWebView;
  late int? allowGuestToView;
  late int? trackViews;
  late int? allowEventsInTimeline;
  late int? allowAutoRepeat;
  late int? quickEntry;
  late int? showPreviewPopup;
  late int? isTree;
  late int? emailAppendTo;
  late int? indexWebPagesForSearch;
  late List<DoctypeField> fields;
  late Map? fieldsMap;

  DoctypeDoc(
      {this.doctype,
      required this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.idx,
      this.docstatus,
      this.searchFields,
      required this.issingle,
      this.istable,
      this.editableGrid,
      this.trackChanges,
      required this.module,
      this.autoname,
      this.nameCase,
      this.titleField,
      this.subjectField,
      this.senderField,
      this.imageField,
      this.sortField,
      this.sortOrder,
      this.description,
      this.readOnly,
      this.inCreate,
      this.allowCopy,
      this.allowRename,
      this.allowImport,
      this.hideToolbar,
      this.trackSeen,
      this.maxAttachments,
      this.documentType,
      this.icon,
      this.engine,
      this.isSubmittable,
      this.showNameInGlobalSearch,
      this.custom,
      this.beta,
      this.hasWebView,
      this.allowGuestToView,
      this.trackViews,
      this.allowEventsInTimeline,
      this.allowAutoRepeat,
      this.quickEntry,
      this.showPreviewPopup,
      this.isTree,
      this.emailAppendTo,
      this.indexWebPagesForSearch,
      required this.fields,
      this.fieldsMap});

  DoctypeDoc.fromJson(Map<dynamic, dynamic> json) {
    doctype = json['doctype'];
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    searchFields = json['search_fields'];
    issingle = json['issingle'];
    istable = json['istable'];
    editableGrid = json['editable_grid'];
    trackChanges = json['track_changes'];
    module = json['module'];
    autoname = json['autoname'];
    nameCase = json['name_case'];
    titleField = json['title_field'];
    subjectField = json['subject_field'];
    senderField = json['sender_field'];
    imageField = json['image_field'];
    sortField = json['sort_field'];
    sortOrder = json['sort_order'];
    description = json['description'];
    readOnly = json['read_only'];
    inCreate = json['in_create'];
    allowCopy = json['allow_copy'];
    allowRename = json['allow_rename'];
    allowImport = json['allow_import'];
    hideToolbar = json['hide_toolbar'];
    trackSeen = json['track_seen'];
    maxAttachments = json['max_attachments'];
    documentType = json['document_type'];
    icon = json['icon'];
    engine = json['engine'];
    isSubmittable = json['is_submittable'];
    showNameInGlobalSearch = json['show_name_in_global_search'];
    custom = json['custom'];
    beta = json['beta'];
    hasWebView = json['has_web_view'];
    allowGuestToView = json['allow_guest_to_view'];
    trackViews = json['track_views'];
    allowEventsInTimeline = json['allow_events_in_timeline'];
    allowAutoRepeat = json['allow_auto_repeat'];
    quickEntry = json['quick_entry'];
    showPreviewPopup = json['show_preview_popup'];
    isTree = json['is_tree'];
    emailAppendTo = json['email_append_to'];
    indexWebPagesForSearch = json['index_web_pages_for_search'];
    fieldsMap = json['field_map'];
    if (json['fields'] != null) {
      fields = [];
      json['fields'].forEach((v) {
        fields.add(new DoctypeField.fromJson(Map<dynamic, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['doctype'] = this.doctype;
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['creation'] = this.creation;
    data['modified'] = this.modified;
    data['modified_by'] = this.modifiedBy;
    data['idx'] = this.idx;
    data['docstatus'] = this.docstatus;
    data['search_fields'] = this.searchFields;
    data['issingle'] = this.issingle;
    data['istable'] = this.istable;
    data['editable_grid'] = this.editableGrid;
    data['track_changes'] = this.trackChanges;
    data['module'] = this.module;
    data['autoname'] = this.autoname;
    data['name_case'] = this.nameCase;
    data['title_field'] = this.titleField;
    data['title_field'] = this.senderField;
    data['title_field'] = this.subjectField;
    data['image_field'] = this.imageField;
    data['sort_field'] = this.sortField;
    data['sort_order'] = this.sortOrder;
    data['description'] = this.description;
    data['read_only'] = this.readOnly;
    data['in_create'] = this.inCreate;
    data['allow_copy'] = this.allowCopy;
    data['allow_rename'] = this.allowRename;
    data['allow_import'] = this.allowImport;
    data['hide_toolbar'] = this.hideToolbar;
    data['track_seen'] = this.trackSeen;
    data['max_attachments'] = this.maxAttachments;
    data['document_type'] = this.documentType;
    data['icon'] = this.icon;
    data['engine'] = this.engine;
    data['is_submittable'] = this.isSubmittable;
    data['show_name_in_global_search'] = this.showNameInGlobalSearch;
    data['custom'] = this.custom;
    data['beta'] = this.beta;
    data['has_web_view'] = this.hasWebView;
    data['allow_guest_to_view'] = this.allowGuestToView;
    data['track_views'] = this.trackViews;
    data['allow_events_in_timeline'] = this.allowEventsInTimeline;
    data['allow_auto_repeat'] = this.allowAutoRepeat;
    data['quick_entry'] = this.quickEntry;
    data['show_preview_popup'] = this.showPreviewPopup;
    data['is_tree'] = this.isTree;
    data['email_append_to'] = this.emailAppendTo;
    data['index_web_pages_for_search'] = this.indexWebPagesForSearch;
    data['fields_map'] = this.fieldsMap;
    data['fields'] = this.fields.map((v) => v.toJson()).toList();
    return data;
  }
}

class DoctypeField {
  late String? doctype;
  late String? name;
  late String? owner;
  late String? creation;
  late String? modified;
  late String? modifiedBy;
  late String? parent;
  late String? parentfield;
  late String? parenttype;
  late int? idx;
  late int? docstatus;
  late String fieldname;
  late String? dependsOn;
  late String? mandatoryDependsOn;
  late String? fetchFrom;
  late String? label;
  late String? fieldtype;
  late String? oldfieldtype;
  late dynamic options;
  late int? searchIndex;
  late int? hidden;
  late int? setOnlyOnce;
  late int? allowInQuickEntry;
  late int? printHide;
  late int? reportHide;
  late int? reqd;
  late int? bold;
  late int? inGlobalSearch;
  late int? collapsible;
  late int? unique;
  late int? noCopy;
  late int? allowOnSubmit;
  late int? showPreviewPopup;
  late int? permlevel;
  late int? ignoreUserPermissions;
  late int? columns;
  late int? inListView;
  late int? inStandardFilter;
  late int? isDefaultFilter;
  late int? inPreview;
  late int? readOnly;
  late int? length;
  late dynamic translatable;
  late int? rememberLastSelectedValue;
  late int? allowBulkEdit;
  late int? printHideIfNoValue;
  late int? inFilter;
  late int? fetchIfEmpty;
  late int? ignoreXssFilter;
  late int? hideBorder;
  late int? hideDays;
  late int? hideSeconds;
  late dynamic defaultValue;
  late int pVisible = 1;

  DoctypeField({
    this.doctype,
    this.name,
    this.owner,
    this.creation,
    this.modified,
    this.modifiedBy,
    this.parent,
    this.parentfield,
    this.parenttype,
    this.idx,
    this.docstatus,
    required this.fieldname,
    required this.label,
    this.dependsOn,
    this.mandatoryDependsOn,
    this.fetchFrom,
    this.fieldtype,
    this.oldfieldtype,
    this.options,
    this.searchIndex,
    this.hidden,
    this.setOnlyOnce,
    this.allowInQuickEntry,
    this.printHide,
    this.reportHide,
    this.reqd,
    this.bold,
    this.inGlobalSearch,
    this.collapsible,
    this.unique,
    this.noCopy,
    this.allowOnSubmit,
    this.showPreviewPopup,
    this.permlevel,
    this.ignoreUserPermissions,
    this.columns,
    this.inListView,
    this.inStandardFilter,
    this.isDefaultFilter = 0,
    this.inPreview,
    this.readOnly,
    this.length,
    this.translatable,
    this.rememberLastSelectedValue,
    this.allowBulkEdit,
    this.printHideIfNoValue,
    this.inFilter,
    this.fetchIfEmpty,
    this.ignoreXssFilter,
    this.hideBorder,
    this.hideDays,
    this.hideSeconds,
    this.defaultValue,
    this.pVisible = 1,
  });

  DoctypeField.fromJson(Map<dynamic, dynamic> json) {
    doctype = json['doctype'];
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    fieldname = json['fieldname'];
    dependsOn = json['depends_on'];
    mandatoryDependsOn = json['mandatory_depends_on'];
    fetchFrom = json['fetch_from'];
    label = json['label'];
    fieldtype = json['fieldtype'];
    oldfieldtype = json['oldfieldtype'];
    options = json['options'];
    searchIndex = json['search_index'];
    hidden = json['hidden'];
    setOnlyOnce = json['set_only_once'];
    allowInQuickEntry = json['allow_in_quick_entry'];
    printHide = json['print_hide'];
    reportHide = json['report_hide'];
    reqd = json['reqd'];
    bold = json['bold'];
    inGlobalSearch = json['in_global_search'];
    collapsible = json['collapsible'];
    unique = json['unique'];
    noCopy = json['no_copy'];
    allowOnSubmit = json['allow_on_submit'];
    showPreviewPopup = json['show_preview_popup'];
    permlevel = json['permlevel'];
    ignoreUserPermissions = json['ignore_user_permissions'];
    columns = json['columns'];
    inListView = json['in_list_view'];
    inStandardFilter = json['in_standard_filter'];
    isDefaultFilter = json['is_default_filter'];
    inPreview = json['in_preview'];
    readOnly = json['read_only'];
    length = json['length'];
    translatable = json['translatable'];
    rememberLastSelectedValue = json['remember_last_selected_value'];
    allowBulkEdit = json['allow_bulk_edit'];
    printHideIfNoValue = json['print_hide_if_no_value'];
    inFilter = json['in_filter'];
    fetchIfEmpty = json['fetch_if_empty'];
    ignoreXssFilter = json['ignore_xss_filter'];
    hideBorder = json['hide_border'];
    hideDays = json['hide_days'];
    hideSeconds = json['hide_seconds'];
    defaultValue = json['default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['doctype'] = this.doctype;
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['creation'] = this.creation;
    data['modified'] = this.modified;
    data['modified_by'] = this.modifiedBy;
    data['parent'] = this.parent;
    data['parentfield'] = this.parentfield;
    data['parenttype'] = this.parenttype;
    data['idx'] = this.idx;
    data['docstatus'] = this.docstatus;
    data['fieldname'] = this.fieldname;
    data['depends_on'] = this.dependsOn;
    data['mandatory_depends_on'] = this.mandatoryDependsOn;
    data['fetch_from'] = this.fetchFrom;
    data['label'] = this.label;
    data['fieldtype'] = this.fieldtype;
    data['oldfieldtype'] = this.oldfieldtype;
    data['options'] = this.options;
    data['search_index'] = this.searchIndex;
    data['hidden'] = this.hidden;
    data['set_only_once'] = this.setOnlyOnce;
    data['allow_in_quick_entry'] = this.allowInQuickEntry;
    data['print_hide'] = this.printHide;
    data['report_hide'] = this.reportHide;
    data['reqd'] = this.reqd;
    data['bold'] = this.bold;
    data['in_global_search'] = this.inGlobalSearch;
    data['collapsible'] = this.collapsible;
    data['unique'] = this.unique;
    data['no_copy'] = this.noCopy;
    data['allow_on_submit'] = this.allowOnSubmit;
    data['show_preview_popup'] = this.showPreviewPopup;
    data['permlevel'] = this.permlevel;
    data['ignore_user_permissions'] = this.ignoreUserPermissions;
    data['columns'] = this.columns;
    data['in_list_view'] = this.inListView;
    data['in_standard_filter'] = this.inStandardFilter;
    data['is_default_filter'] = this.isDefaultFilter;
    data['in_preview'] = this.inPreview;
    data['read_only'] = this.readOnly;
    data['length'] = this.length;
    data['translatable'] = this.translatable;
    data['remember_last_selected_value'] = this.rememberLastSelectedValue;
    data['allow_bulk_edit'] = this.allowBulkEdit;
    data['print_hide_if_no_value'] = this.printHideIfNoValue;
    data['in_filter'] = this.inFilter;
    data['fetch_if_empty'] = this.fetchIfEmpty;
    data['ignore_xss_filter'] = this.ignoreXssFilter;
    data['hide_border'] = this.hideBorder;
    data['hide_days'] = this.hideDays;
    data['hide_seconds'] = this.hideSeconds;
    data['default'] = this.defaultValue;
    return data;
  }
}
