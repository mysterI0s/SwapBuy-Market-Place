import 'package:swapbuy/Model/Buyer.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/ProductModel.dart';
import 'package:swapbuy/Model/User.dart';

class SwapModel {
  SwapRequest? swapRequest;
  Requester? requester;
  ProductOffered? productOffered;
  ProductOffered? productRequested;
  Address? selectedAddress;

  SwapModel({
    this.swapRequest,
    this.requester,
    this.productOffered,
    this.productRequested,
    this.selectedAddress,
  });

  SwapModel.fromJson(Map<String, dynamic> json) {
    swapRequest =
        json['swap_request'] != null
            ? new SwapRequest.fromJson(json['swap_request'])
            : null;
    requester =
        json['requester'] != null
            ? new Requester.fromJson(json['requester'])
            : null;
    productOffered =
        json['product_offered'] != null
            ? new ProductOffered.fromJson(json['product_offered'])
            : null;
    productRequested =
        json['product_requested'] != null
            ? new ProductOffered.fromJson(json['product_requested'])
            : null;
    selectedAddress =
        json['selected_address'] != null
            ? new Address.fromJson(json['selected_address'])
            : null;
  }
}

class SwapRequest {
  int? id;
  String? createdAt;
  String? status;
  String? paymentMethod;
  var paymentStatus;
  String? deliveryType;
  int? requester;
  int? productOffered;
  int? productRequested;
  int? idAddress;

  SwapRequest({
    this.id,
    this.createdAt,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveryType,
    this.requester,
    this.productOffered,
    this.productRequested,
    this.idAddress,
  });

  SwapRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    status = json['status'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    deliveryType = json['delivery_type'];
    requester = json['requester'];
    productOffered = json['product_offered'];
    productRequested = json['product_requested'];
    idAddress = json['id_address'];
  }
}

class Requester {
  User? user;
  String? birthDate;

  Requester({this.user, this.birthDate});

  Requester.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    birthDate = json['birth_date'];
  }
}

class ProductOffered {
  ProductModel? product;
  Address? address;
  Buyer? seller;

  ProductOffered({this.product, this.address, this.seller});

  ProductOffered.fromJson(Map<String, dynamic> json) {
    product =
        json['product'] != null
            ? new ProductModel.fromJson(json['product'])
            : null;
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    seller = json['seller'] != null ? Buyer.fromJson(json['seller']) : null;
  }
}
