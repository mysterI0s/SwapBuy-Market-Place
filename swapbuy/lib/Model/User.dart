import 'package:swapbuy/Model/Address.dart';

class User {
  int? id;
  int? userIdForChat; // Abstract user ID for chat
  String? username;
  String? name;
  String? phone;
  String? email;
  String? gender;
  var profileImage;
  Address? address;

  User({
    this.id,
    this.username,
    this.name,
    this.phone,
    this.email,
    this.gender,
    this.profileImage,
    this.address,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // Use abstract_user_id if present, else nested user.id, else id
    userIdForChat =
        json['abstract_user_id'] ??
        (json['user'] != null && json['user']['id'] != null
            ? json['user']['id']
            : json['id']);
    username = json['username'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    gender = json['gender'];
    profileImage = json['profile_image'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
  }
}
