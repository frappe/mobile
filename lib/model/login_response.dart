class LoginResponse {
  late String message;
  late String homePage;
  late String fullName;
  late String userId;

  LoginResponse({
    required this.message,
    required this.homePage,
    required this.fullName,
    required this.userId,
  });

  LoginResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    homePage = json['home_page'];
    fullName = json['full_name'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['home_page'] = this.homePage;
    data['full_name'] = this.fullName;
    data['user_id'] = this.userId;
    return data;
  }
}
