class DesktopPageResponse {
  late DesktopPageMessage message;

  DesktopPageResponse({required this.message});

  DesktopPageResponse.fromJson(Map<dynamic, dynamic> json) {
    message = DesktopPageMessage.fromJson(json['message']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message.toJson();
    return data;
  }
}

class DesktopPageMessage {
  late DesktopPageCharts charts;
  late DesktopPageShortcuts shortcuts;
  late DesktopPageCards cards;
  late bool allowCustomization;

  DesktopPageMessage({
    required this.charts,
    required this.shortcuts,
    required this.cards,
    required this.allowCustomization,
  });

  DesktopPageMessage.fromJson(Map<dynamic, dynamic> json) {
    charts = DesktopPageCharts.fromJson(json['charts']);

    shortcuts = DesktopPageShortcuts.fromJson(json['shortcuts']);
    cards = DesktopPageCards.fromJson(json['cards']);

    allowCustomization = json['allow_customization'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['charts'] = this.charts.toJson();
    data['shortcuts'] = this.shortcuts.toJson();
    data['cards'] = this.cards.toJson();
    data['allow_customization'] = this.allowCustomization;
    return data;
  }
}

class DesktopPageCharts {
  late String? label;
  late List<ChartItem>? items;

  DesktopPageCharts({this.label, this.items});

  DesktopPageCharts.fromJson(Map<dynamic, dynamic> json) {
    label = json['label'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(new ChartItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    if (this.items != null) {
      data['items'] = this.items?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DesktopPageShortcuts {
  late String label;
  late List<ShortcutItem> items;

  DesktopPageShortcuts({
    required this.label,
    required this.items,
  });

  DesktopPageShortcuts.fromJson(Map<dynamic, dynamic> json) {
    label = json['label'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(new ShortcutItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['items'] = this.items.map((v) => v.toJson()).toList();
    return data;
  }
}

class DesktopPageCards {
  late String label;
  late List<CardItem> items;

  DesktopPageCards({
    required this.label,
    required this.items,
  });

  DesktopPageCards.fromJson(Map<dynamic, dynamic> json) {
    label = json['label'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(CardItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['items'] = this.items.map((v) => v.toJson()).toList();
    return data;
  }
}

class ChartItem {
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
  late String? chartName;
  late String? label;
  late String? doctype;

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
  late String? type;
  late String linkTo;
  late String? docView;
  late String label;
  late dynamic? icon;
  late dynamic? restrictToDomain;
  late String? statsFilter;
  late String? color;
  late String? format;
  late String? doctype;
  late int? isQueryReport;

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
      required this.linkTo,
      this.docView,
      required this.label,
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
  late String label;
  late dynamic hidden;
  late List<CardItemLink> links;
  late String? doctype;

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
      required this.label,
      this.hidden,
      required this.links,
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
      links = [];
      json['links'].forEach((v) {
        links.add(CardItemLink.fromJson(v));
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
    data['links'] = this.links.map((v) => v.toJson()).toList();
    data['doctype'] = this.doctype;
    return data;
  }
}

class CardItemLink {
  late String? description;
  late String label;
  late String name;
  late int? onboard;
  late String? type;
  late dynamic? count;
  late dynamic? dependencies;
  late String? doctype;
  late dynamic? isQueryReport;
  late dynamic? incompleteDependencies;
  late String? icon;
  late String? linkTo;

  CardItemLink(
      {this.description,
      required this.label,
      required this.name,
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
