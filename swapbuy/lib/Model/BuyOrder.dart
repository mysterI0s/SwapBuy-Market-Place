import 'package:swapbuy/Constant/order_status.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/User.dart';

class BuyOrder {
  int? orderId;
  double? totalAmount;
  String? status;
  String? createdAt;
  String? orderStatus;
  int? idDelivery;
  String? deliveryType;
  String? paymentMethod;
  String? paymentStatus;
  Address? deliveryAddress;
  User? buyer;
  User? seller;
  ProductInfo? product;

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

  BuyOrder({
    this.orderId,
    this.totalAmount,
    this.status,
    this.createdAt,
    this.orderStatus,
    this.idDelivery,
    this.deliveryType,
    this.paymentMethod,
    this.paymentStatus,
    this.deliveryAddress,
    this.buyer,
    this.seller,
    this.product,
    this.buyerDeliveryRating,
    this.buyerDeliveryComment,
    this.sellerDeliveryRating,
    this.sellerDeliveryComment,
    this.sellerRating,
    this.sellerComment,
    this.buyerRating,
    this.buyerComment,
  });

  BuyOrder.fromJson(Map<String, dynamic> json) {
    try {
      orderId = json['order_id'];
      totalAmount = json['total_amount']?.toDouble();
      status = json['status'];
      createdAt = json['created_at'];
      // Sync status and orderStatus for consistency
      status = json['status'] ?? json['order_status'];
      orderStatus = json['order_status'] ?? json['status'];
      idDelivery = json['id_delivery'];
      deliveryType = json['delivery_type'];
      paymentMethod = json['payment_method'];
      paymentStatus = json['payment_status'];

      deliveryAddress =
          json['delivery_address'] != null
              ? Address.fromJson(json['delivery_address'])
              : null;

      buyer = json['buyer'] != null ? User.fromJson(json['buyer']) : null;

      seller = json['seller'] != null ? User.fromJson(json['seller']) : null;

      // Handle products structure from API response
      if (json['products'] != null && json['products']['requested'] != null) {
        product = ProductInfo.fromJson(json['products']['requested']);
      } else if (json['product'] != null) {
        // Handle direct product object
        product = ProductInfo.fromJson(json['product']);
      }

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
        // Fallback: try to parse directly from root level (for backward compatibility)
        buyerDeliveryRating = json['buyer_delivery_rating'];
        buyerDeliveryComment = json['buyer_delivery_comment'];
        sellerDeliveryRating = json['seller_delivery_rating'];
        sellerDeliveryComment = json['seller_delivery_comment'];
        sellerRating = json['seller_rating'];
        sellerComment = json['seller_comment'];
        buyerRating = json['buyer_rating'];
        buyerComment = json['buyer_comment'];
      }
    } catch (e) {
      rethrow;
    }
  }

  OrderStatus get orderStatusEnum =>
      OrderStatus.fromString(orderStatus ?? 'Pending');
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
