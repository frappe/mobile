class LoginResponse {
  late String? message;
  late String? homePage;
  late String? fullName;
  late String? userId;
  late Verification? verification;
  late String? tmpId;

  LoginResponse({
    this.message,
    this.homePage,
    this.fullName,
    this.userId,
    this.verification,
    this.tmpId,
  });

  LoginResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    homePage = json['home_page'];
    fullName = json['full_name'];
    userId = json['user_id'];
    verification = json['verification'] != null
        ? new Verification.fromJson(json['verification'])
        : null;
    tmpId = json['tmp_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['home_page'] = this.homePage;
    data['full_name'] = this.fullName;
    data['user_id'] = this.userId;
    if (this.verification != null) {
      data['verification'] = this.verification!.toJson();
    }
    data['tmp_id'] = this.tmpId;
    return data;
  }
}

class Verification {
  late bool tokenDelivery;
  late String prompt;
  late String method;
  late bool setup;

  Verification({
    required this.tokenDelivery,
    required this.prompt,
    required this.method,
    required this.setup,
  });

  Verification.fromJson(Map<String, dynamic> json) {
    tokenDelivery = json['token_delivery'];
    prompt = json['prompt'];
    method = json['method'];
    setup = json['setup'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token_delivery'] = this.tokenDelivery;
    data['prompt'] = this.prompt;
    data['method'] = this.method;
    data['setup'] = this.setup;
    return data;
  }
}
