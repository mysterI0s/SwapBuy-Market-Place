import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/Buyer.dart';
import 'package:swapbuy/Model/ProductModel.dart';

class ProductFull {
  ProductModel? product;
  Address? address;
  Buyer? buyer;

  ProductFull({this.product, this.address, this.buyer});

  ProductFull.fromJson(Map<String, dynamic> json) {
    product =
        json['product'] != null ? ProductModel.fromJson(json['product']) : null;
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    buyer = json['buyer'] != null ? Buyer.fromJson(json['buyer']) : null;
  }
}
