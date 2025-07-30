import 'package:swapbuy/Model/User.dart';

class ProfileDelivery {
  int? IdDelivery;
  User? user;
  String? birthDate;
  String? identity_number;
  String? city;
  String? address;

  ProfileDelivery({
    this.IdDelivery,
    this.user,
    this.birthDate,
    this.identity_number,
    this.city,
    this.address,
  });

  ProfileDelivery.fromJson(Map<String, dynamic> json) {
    IdDelivery = json['delivery_id'];
    user =
        json['delivery_data']['user'] != null
            ? new User.fromJson(json['delivery_data']['user'])
            : null;
    birthDate = json['delivery_data']['birth_date'];
    identity_number = json['delivery_data']['identity_number'];
    city = json['delivery_data']['city'];
    address = json['delivery_data']['address'];
  }
}
