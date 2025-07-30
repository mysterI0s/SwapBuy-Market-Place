import 'package:swapbuy/Constant/order_status.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/User.dart';

class SwapOrder {
  int? orderId;
  int? swapRequestId;
  double? totalAmount;
  String? status;
  String? createdAt;
  String? orderStatus;
  int? idDelivery;
  String? deliveryType;
  String? paymentMethod;
  String? paymentStatus;
  PayerOfDifference? payerOfDifference;
  Address? deliveryAddress;
  User? seller;
  User? buyer;
  ProductInfo? productOffered;
  ProductInfo? productRequested;

  // New separate delivery ratings
  int? buyerDeliveryRating;
  String? buyerDeliveryComment;
  int? sellerDeliveryRating;
  String? sellerDeliveryComment;

  // User ratings
  int? sellerRating;
  String? sellerComment;
  int? buyerRating;
  String? buyerComment;

  SwapOrder({
    this.orderId,
    this.totalAmount,
    this.status,
    this.createdAt,
    this.orderStatus,
    this.idDelivery,
    this.deliveryType,
    this.paymentMethod,
    this.paymentStatus,
    this.payerOfDifference,
    this.deliveryAddress,
    this.seller,
    this.buyer,
    this.productOffered,
    this.productRequested,
    this.buyerDeliveryRating,
    this.buyerDeliveryComment,
    this.sellerDeliveryRating,
    this.sellerDeliveryComment,
    this.sellerRating,
    this.sellerComment,
    this.buyerRating,
    this.buyerComment,
  });

  SwapOrder.fromJson(Map<String, dynamic> json) {
    try {
      // Handle both old and new API formats for order ID
      orderId = json['order_id'] ?? json['id'];
      swapRequestId =
          json['swap_request_id'] ??
          json['swap_request'] ??
          json['swapRequestId'];
      totalAmount = json['total_amount']?.toDouble();
      // Sync status and orderStatus for consistency
      status = json['status'] ?? json['order_status'];
      orderStatus = json['order_status'] ?? json['status'];
      createdAt = json['created_at'];
      idDelivery = json['id_delivery'];
      deliveryType = json['delivery_type'];
      paymentMethod = json['payment_method'];
      paymentStatus = json['payment_status'];

      payerOfDifference =
          json['payer_of_difference'] != null
              ? PayerOfDifference.fromJson(json['payer_of_difference'])
              : null;

      deliveryAddress =
          json['delivery_address'] != null
              ? Address.fromJson(json['delivery_address'])
              : null;

      seller = json['seller'] != null ? User.fromJson(json['seller']) : null;
      buyer = json['buyer'] != null ? User.fromJson(json['buyer']) : null;

      // Parse ratings from the nested 'ratings' object if present
      if (json['ratings'] != null) {
        final ratingsData = json['ratings'];
        // Delivery ratings
        buyerDeliveryRating = ratingsData['delivery_rating_by_buyer'];
        buyerDeliveryComment = ratingsData['delivery_comment_by_buyer'];
        // Try ratings object first, fallback to root if missing
        sellerDeliveryRating =
            ratingsData['delivery_rating_by_seller'] ??
            json['seller_delivery_rating'];
        sellerDeliveryComment =
            ratingsData['delivery_comment_by_seller'] ??
            json['seller_delivery_comment'];
        // User ratings
        sellerRating = ratingsData['seller_rating'];
        sellerComment = ratingsData['seller_comment'];
        buyerRating = ratingsData['buyer_rating'];
        buyerComment = ratingsData['buyer_comment'];
      } else {
        // Fallback to old structure if ratings not nested
        buyerDeliveryRating = json['buyer_delivery_rating'];
        buyerDeliveryComment = json['buyer_delivery_comment'];
        sellerDeliveryRating = json['seller_delivery_rating'];
        sellerDeliveryComment = json['seller_delivery_comment'];
        sellerRating = json['seller_rating'];
        sellerComment = json['seller_comment'];
        buyerRating = json['buyer_rating'];
        buyerComment = json['buyer_comment'];
      }

      // Handle products structure from API response
      if (json['products'] != null) {
        productOffered =
            json['products']['offered'] != null
                ? ProductInfo.fromJson(json['products']['offered'])
                : null;
        productRequested =
            json['products']['requested'] != null
                ? ProductInfo.fromJson(json['products']['requested'])
                : null;
      }
    } catch (e) {
      rethrow;
    }
  }

  OrderStatus get orderStatusEnum =>
      OrderStatus.fromString(orderStatus ?? 'Pending');
}

class PayerOfDifference {
  int? id;
  String? name;

  PayerOfDifference({this.id, this.name});

  PayerOfDifference.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
    } catch (e) {
      rethrow;
    }
  }
}

class ProductInfo {
  int? id;
  String? name;
  double? price;
  String? status;
  String? condition;

  ProductInfo({this.id, this.name, this.price, this.status, this.condition});

  ProductInfo.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      price = json['price']?.toDouble();
      status = json['status'];
      condition = json['condition'];
    } catch (e) {
      rethrow;
    }
  }
}
