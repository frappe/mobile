class DeskSidebarItemsResponse {
  DeskMessage message;

  DeskSidebarItemsResponse({this.message});

  DeskSidebarItemsResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'] != null
        ? new DeskMessage.fromJson(json['message'])
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

class DeskMessage {
  List<DeskItem> modules;
  List<DeskItem> administration;
  List<DeskItem> domains;

  DeskMessage({this.modules, this.administration, this.domains});

  DeskMessage.fromJson(Map<String, dynamic> json) {
    if (json['Modules'] != null) {
      modules = new List<DeskItem>();
      json['Modules'].forEach((v) {
        modules.add(new DeskItem.fromJson(v));
      });
    }
    if (json['Administration'] != null) {
      administration = new List<DeskItem>();
      json['Administration'].forEach((v) {
        administration.add(new DeskItem.fromJson(v));
      });
    }
    if (json['Domains'] != null) {
      domains = new List<DeskItem>();
      json['Domains'].forEach((v) {
        domains.add(new DeskItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.modules != null) {
      data['Modules'] = this.modules.map((v) => v.toJson()).toList();
    }
    if (this.administration != null) {
      data['Administration'] =
          this.administration.map((v) => v.toJson()).toList();
    }
    if (this.domains != null) {
      data['Domains'] = this.domains.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeskItem {
  String name;
  String category;
  String module;
  String label;

  DeskItem({this.name, this.category, this.module, this.label});

  DeskItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    category = json['category'];
    module = json['module'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['category'] = this.category;
    data['module'] = this.module;
    data['label'] = this.label;
    return data;
  }
}
