import 'package:swapbuy/Model/User.dart';

class ProfileUser {
  User? user;
  String? birthDate;

  ProfileUser({this.user, this.birthDate});

  ProfileUser.fromJson(Map<String, dynamic> json) {
    user =
        json['user_application_data']['user'] != null
            ? new User.fromJson(json['user_application_data']['user'])
            : null;
    birthDate = json['user_application_data']['birth_date'];
  }
}
