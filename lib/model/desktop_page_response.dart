// @dart=2.9

class DesktopPageResponse {
  DesktopPageMessage message;

  DesktopPageResponse({this.message});

  DesktopPageResponse.fromJson(Map<dynamic, dynamic> json) {
    message = json['message'] != null
        ? new DesktopPageMessage.fromJson(json['message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.message != null) {
      data['message'] = this.message.toJson();
    }
    return data;
  }
}

class DesktopPageMessage {
  DesktopPageCharts charts;
  DesktopPageShortcuts shortcuts;
  DesktopPageCards cards;
  bool allowCustomization;

  DesktopPageMessage(
      {this.charts, this.shortcuts, this.cards, this.allowCustomization});

  DesktopPageMessage.fromJson(Map<dynamic, dynamic> json) {
    charts = json['charts'] != null
        ? new DesktopPageCharts.fromJson(json['charts'])
        : null;
    shortcuts = json['shortcuts'] != null
        ? new DesktopPageShortcuts.fromJson(json['shortcuts'])
        : null;
    cards = json['cards'] != null
        ? new DesktopPageCards.fromJson(json['cards'])
        : null;
    allowCustomization = json['allow_customization'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.charts != null) {
      data['charts'] = this.charts.toJson();
    }
    if (this.shortcuts != null) {
      data['shortcuts'] = this.shortcuts.toJson();
    }
    if (this.cards != null) {
      data['cards'] = this.cards.toJson();
    }
    data['allow_customization'] = this.allowCustomization;
    return data;
  }
}

class DesktopPageCharts {
  String label;
  List<ChartItem> items;

  DesktopPageCharts({this.label, this.items});

  DesktopPageCharts.fromJson(Map<dynamic, dynamic> json) {
    label = json['label'];
    if (json['items'] != null) {
      items = new List<ChartItem>();
      json['items'].forEach((v) {
        items.add(new ChartItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DesktopPageShortcuts {
  String label;
  List<ShortcutItem> items;

  DesktopPageShortcuts({this.label, this.items});

  DesktopPageShortcuts.fromJson(Map<dynamic, dynamic> json) {
    label = json['label'];
    if (json['items'] != null) {
      items = new List<ShortcutItem>();
      json['items'].forEach((v) {
        items.add(new ShortcutItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DesktopPageCards {
  String label;
  List<CardItem> items;

  DesktopPageCards({this.label, this.items});

  DesktopPageCards.fromJson(Map<dynamic, dynamic> json) {
    label = json['label'];
    if (json['items'] != null) {
      items = new List<CardItem>();
      json['items'].forEach((v) {
        items.add(new CardItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChartItem {
  String name;
  String owner;
  String creation;
  String modified;
  String modifiedBy;
  String parent;
  String parentfield;
  String parenttype;
  int idx;
  int docstatus;
  String chartName;
  String label;
  String doctype;

  ChartItem(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.chartName,
      this.label,
      this.doctype});

  ChartItem.fromJson(Map<dynamic, dynamic> json) {
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
    chartName = json['chart_name'];
    label = json['label'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['chart_name'] = this.chartName;
    data['label'] = this.label;
    data['doctype'] = this.doctype;
    return data;
  }
}

class ShortcutItem {
  String name;
  String owner;
  String creation;
  String modified;
  String modifiedBy;
  String parent;
  String parentfield;
  String parenttype;
  int idx;
  int docstatus;
  String type;
  String linkTo;
  String docView;
  String label;
  dynamic icon;
  dynamic restrictToDomain;
  String statsFilter;
  String color;
  String format;
  String doctype;
  int isQueryReport;

  ShortcutItem(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.type,
      this.linkTo,
      this.docView,
      this.label,
      this.icon,
      this.restrictToDomain,
      this.statsFilter,
      this.color,
      this.format,
      this.doctype,
      this.isQueryReport});

  ShortcutItem.fromJson(Map<dynamic, dynamic> json) {
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
    type = json['type'];
    linkTo = json['link_to'];
    docView = json['doc_view'];
    label = json['label'];
    icon = json['icon'];
    restrictToDomain = json['restrict_to_domain'];
    statsFilter = json['stats_filter'];
    color = json['color'];
    format = json['format'];
    doctype = json['doctype'];
    isQueryReport = json['is_query_report'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['type'] = this.type;
    data['link_to'] = this.linkTo;
    data['doc_view'] = this.docView;
    data['label'] = this.label;
    data['icon'] = this.icon;
    data['restrict_to_domain'] = this.restrictToDomain;
    data['stats_filter'] = this.statsFilter;
    data['color'] = this.color;
    data['format'] = this.format;
    data['doctype'] = this.doctype;
    data['is_query_report'] = this.isQueryReport;
    return data;
  }
}

class CardItem {
  String name;
  String owner;
  String creation;
  String modified;
  String modifiedBy;
  String parent;
  String parentfield;
  String parenttype;
  int idx;
  int docstatus;
  String label;
  int hidden;
  List<CardItemLink> links;
  String doctype;

  CardItem(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.label,
      this.hidden,
      this.links,
      this.doctype});

  CardItem.fromJson(Map<dynamic, dynamic> json) {
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
    label = json['label'];
    hidden = json['hidden'];
    if (json['links'] != null) {
      links = new List<CardItemLink>();
      json['links'].forEach((v) {
        links.add(new CardItemLink.fromJson(v));
      });
    }
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['label'] = this.label;
    data['hidden'] = this.hidden;
    if (this.links != null) {
      data['links'] = this.links.map((v) => v.toJson()).toList();
    }
    data['doctype'] = this.doctype;
    return data;
  }
}

class CardItemLink {
  String description;
  String label;
  String name;
  int onboard;
  String type;
  dynamic count;
  dynamic dependencies;
  String doctype;
  dynamic isQueryReport;
  dynamic incompleteDependencies;
  String icon;
  String linkTo;

  CardItemLink(
      {this.description,
      this.label,
      this.name,
      this.onboard,
      this.type,
      this.count,
      this.dependencies,
      this.doctype,
      this.isQueryReport,
      this.incompleteDependencies,
      this.icon,
      this.linkTo});

  CardItemLink.fromJson(Map<dynamic, dynamic> json) {
    description = json['description'];
    label = json['label'];
    name = json['name'];
    onboard = json['onboard'];
    type = json['type'];
    count = json['count'];
    dependencies = json['dependencies'];
    doctype = json['doctype'];
    isQueryReport = json['is_query_report'];
    incompleteDependencies = json['incomplete_dependencies'];
    icon = json['icon'];
    linkTo = json['link_to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['label'] = this.label;
    data['name'] = this.name;
    data['onboard'] = this.onboard;
    data['type'] = this.type;
    data['count'] = this.count;
    data['dependencies'] = this.dependencies;
    data['doctype'] = this.doctype;
    data['is_query_report'] = this.isQueryReport;
    data['incomplete_dependencies'] = this.incompleteDependencies;
    data['icon'] = this.icon;
    data['link_to'] = this.linkTo;
    return data;
  }
}
