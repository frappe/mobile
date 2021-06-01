class GroupByCountResponse {
  late List<Message> message;

  GroupByCountResponse({required this.message});

  GroupByCountResponse.fromJson(Map<String, dynamic> json) {
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
  late String name;
  late int count;

  Message({required this.name, required this.count});

  Message.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['count'] = this.count;
    return data;
  }
}
