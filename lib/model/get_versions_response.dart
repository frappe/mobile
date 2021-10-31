class GetVersionsResponse {
  late Message message;

  GetVersionsResponse({required this.message});

  GetVersionsResponse.fromJson(Map<String, dynamic> json) {
    message = Message.fromJson(json['message']);
  }
}

class Message {
  Map<String, FrappeApp> frappeApps = {};

  Message.fromJson(Map<String, dynamic> json) {
    json.entries.forEach(
      (entry) {
        var k = entry.key;
        var v = entry.value;
        frappeApps[k] = FrappeApp.fromJson(v);
      },
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    frappeApps.forEach((key, value) {
      data[key] = value.toJson();
    });
    return data;
  }
}

class FrappeApp {
  String? title;
  String? description;
  String? branch;
  String? branchVersion;
  String? version;

  FrappeApp(
      {this.title,
      this.description,
      this.branch,
      this.branchVersion,
      this.version});

  FrappeApp.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    branch = json['branch'];
    branchVersion = json['branch_version'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['branch'] = this.branch;
    data['branch_version'] = this.branchVersion;
    data['version'] = this.version;
    return data;
  }
}
