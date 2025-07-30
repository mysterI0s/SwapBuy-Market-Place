class ProductModel {
  int? id;
  String? name;
  String? description;
  var price;
  int? quantityAvailable;
  String? image;
  String? videoFile;
  String? addedAt;
  String? condition;
  String? status;
  int? idBuyer;
  int? idAddress;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.quantityAvailable,
    this.image,
    this.videoFile,
    this.addedAt,
    this.condition,
    this.status,
    this.idBuyer,
    this.idAddress,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    quantityAvailable = json['quantity_available'];
    image = json['image'];
    videoFile = json['video_file'];
    addedAt = json['added_at'];
    condition = json['condition'];
    status = json['status'];
    idBuyer = json['id_buyer'];
    idAddress = json['id_address'];
  }
}
