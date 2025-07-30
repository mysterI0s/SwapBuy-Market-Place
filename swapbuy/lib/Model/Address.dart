class Address {
  int? id;
  String? street;
  String? neighborhood;
  String? buildingNumber;
  String? city;
  String? description;
  String? postalCode;
  String? country;
  int? user;

  Address({
    this.id,
    this.street,
    this.neighborhood,
    this.buildingNumber,
    this.city,
    this.description,
    this.postalCode,
    this.country,
    this.user,
  });

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    street = json['street'];
    neighborhood = json['neighborhood'];
    buildingNumber = json['building_number'];
    city = json['city'];
    description = json['description'];
    postalCode = json['postal_code'];
    country = json['country'];
    user = json['user'];
  }
}
