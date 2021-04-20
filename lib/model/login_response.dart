// @dart=2.9

class LoginResponse {
  String message;
  String homePage;
  String fullName;
  String userId;

  LoginResponse({this.message, this.homePage, this.fullName, this.userId});

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
