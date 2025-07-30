import 'package:swapbuy/Model/User.dart';

class Buyer {
  User? user;
  String? birthDate;

  Buyer({this.user, this.birthDate});

  Buyer.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    birthDate = json['birth_date'];
  }
}
