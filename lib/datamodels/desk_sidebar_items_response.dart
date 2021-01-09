class DeskSidebarItemsResponse {
  List<DeskMessage> message;

  DeskSidebarItemsResponse({this.message});

  DeskSidebarItemsResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] != null) {
      message = new List<DeskMessage>();
      json['message'].forEach((v) {
        message.add(new DeskMessage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.message != null) {
      data['message'] = this.message.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeskMessage {
  String name;
  String category;
  String icon;
  String module;
  String label;

  DeskMessage({this.name, this.category, this.icon, this.module, this.label});

  DeskMessage.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    category = json['category'];
    icon = json['icon'];
    module = json['module'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['category'] = this.category;
    data['icon'] = this.icon;
    data['module'] = this.module;
    data['label'] = this.label;
    return data;
  }
}
