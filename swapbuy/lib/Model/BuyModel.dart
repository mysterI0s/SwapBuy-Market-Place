import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/ProductModel.dart';
import 'package:swapbuy/Model/SwapModel.dart';

class BuyModel {
  BuyRequest? buyRequest;
  Requester? requester;
  ProductRequested? productRequested;
  Address? selectedAddress;

  BuyModel({
    this.buyRequest,
    this.requester,
    this.productRequested,
    this.selectedAddress,
  });

  BuyModel.fromJson(Map<String, dynamic> json) {
    buyRequest =
        json['buy_request'] != null
            ? new BuyRequest.fromJson(json['buy_request'])
            : null;
    requester =
        json['requester'] != null
            ? new Requester.fromJson(json['requester'])
            : null;
    productRequested =
        json['product_requested'] != null
            ? new ProductRequested.fromJson(json['product_requested'])
            : null;
    selectedAddress =
        json['selected_address'] != null
            ? new Address.fromJson(json['selected_address'])
            : null;
  }
}

class BuyRequest {
  int? id;
  String? createdAt;
  String? status;
  String? paymentMethod;
  String? paymentStatus;
  String? deliveryType;
  int? requester;
  int? productRequested;
  int? idAddress;

  BuyRequest({
    this.id,
    this.createdAt,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveryType,
    this.requester,
    this.productRequested,
    this.idAddress,
  });

  BuyRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    status = json['status'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    deliveryType = json['delivery_type'];
    requester = json['requester'];
    productRequested = json['product_requested'];
    idAddress = json['id_address'];
  }
}

class ProductRequested {
  ProductModel? product;
  Address? address;
  Requester? buyer;

  ProductRequested({this.product, this.address, this.buyer});

  ProductRequested.fromJson(Map<String, dynamic> json) {
    product =
        json['product'] != null
            ? new ProductModel.fromJson(json['product'])
            : null;
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    buyer =
        json['buyer'] != null ? new Requester.fromJson(json['buyer']) : null;
  }
}
