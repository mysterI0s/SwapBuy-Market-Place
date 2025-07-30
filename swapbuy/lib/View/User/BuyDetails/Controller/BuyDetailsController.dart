import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/BuyModel.dart';
import 'package:swapbuy/Model/BuyOrder.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Model/SwapModel.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/User/AcceptanceCase/Controller/AcceptanceCaseController.dart';
import 'package:swapbuy/View/User/IncomingRequests/Controller/IncomingRequestsController.dart';

class BuyDetailsController with ChangeNotifier {
  ProductRequested? productrequest;
  ProductOffered? productoffered;
  int? idbuy;
  BuyModel? buymodel;
  BuyOrder? buyOrder;
  AcceptanceCaseController? caseController;
  IncomingRequestsController? incomingRequestsController;

  // Rating state
  int sellerRating = 0;
  String sellerComment = '';
  bool sellerRatingSubmitted = false;

  int deliveryRating = 0;
  String deliveryComment = '';
  bool deliveryRatingSubmitted = false;
  String? currentRaterType;

  initstate(
    BuildContext context,
    BuyModel buymodel, {
    AcceptanceCaseController? caseController,
    IncomingRequestsController? incomingRequestsController,
  }) async {
    await AllAddress(context);
    this.buymodel = buymodel;
    this.caseController = caseController;
    this.incomingRequestsController = incomingRequestsController;
    idbuy = buymodel.buyRequest!.id!;
    productrequest = buymodel.productRequested;

    if (incomingRequestsController == null) {
      address =
          adresses
              .where((element) => element.id == buymodel.selectedAddress!.id!)
              .first;
    }
    deliverymethod = buymodel.buyRequest!.deliveryType!;
    paymentmethod = buymodel.buyRequest!.paymentMethod!;

    // Fetch order details to get order status for rating functionality
    await fetchOrderDetails(context);
    notifyListeners();
  }

  // Add method to fetch order details
  Future<void> fetchOrderDetails(BuildContext context) async {
    if (idbuy == null) {
      log('[fetchOrderDetails] idbuy is null, cannot fetch buy request.');
      return;
    }

    final client = Provider.of<NetworkClient>(context, listen: false);

    try {
      log('[fetchOrderDetails] Fetching buy request for idbuy: $idbuy');
      final buyRequestResponse = await client.request(
        path: '/Service/api/buy-requests/$idbuy/',
        requestType: RequestType.GET,
      );

      log(
        '[fetchOrderDetails] BuyRequest response status: ${buyRequestResponse.statusCode}',
      );
      log(
        '[fetchOrderDetails] BuyRequest response body: ${buyRequestResponse.body}',
      );

      if (buyRequestResponse.statusCode == 200) {
        final buyRequestData = jsonDecode(buyRequestResponse.body);

        // Check if order exists
        if (buyRequestData.containsKey('order') &&
            buyRequestData['order'] != null) {
          final orderData = buyRequestData['order'];
          if (orderData != null && orderData['id'] != null) {
            final orderId = orderData['id'];
            log(
              '[fetchOrderDetails] Found orderId $orderId in buy request. Fetching order details...',
            );

            // Fetch detailed order information
            final orderResponse = await client.request(
              path: '/Service/api/buy-orders/$orderId/detail/',
              requestType: RequestType.GET,
            );

            log(
              '[fetchOrderDetails] Order details response status: ${orderResponse.statusCode}',
            );
            log(
              '[fetchOrderDetails] Order details response body: ${orderResponse.body}',
            );

            if (orderResponse.statusCode == 200) {
              final orderDetails = jsonDecode(orderResponse.body);
              buyOrder = BuyOrder.fromJson(orderDetails);
              log(
                '[fetchOrderDetails] buyOrder updated from order details endpoint.',
              );
              _initializeRatingState();
            } else {
              log(
                '[fetchOrderDetails] Failed to fetch order details: ${orderResponse.statusCode}',
              );
              // Fallback to basic order data
              buyOrder = BuyOrder.fromJson(orderData);
              _initializeRatingState();
            }
          } else {
            log('[fetchOrderDetails] orderData is missing id.');
            buyOrder = null;
          }
        } else {
          log(
            '[fetchOrderDetails] No order associated with this buy request yet.',
          );
          buyOrder = null;
        }
      } else {
        log(
          '[fetchOrderDetails] Failed to fetch buy request: ${buyRequestResponse.statusCode}',
        );
        buyOrder = null;
      }
    } catch (e) {
      log('[fetchOrderDetails] Error fetching buy request: $e');
      buyOrder = null;
    }
    notifyListeners();
  }

  // Check if order is delivered and can be rated
  bool get canRateOrder {
    return buyOrder?.orderStatus?.toLowerCase() == 'delivered';
  }

  // Determine current user's role in the order
  String get currentUserRole {
    if (incomingRequestsController != null) {
      return 'seller'; // In incoming requests, current user is the seller
    } else {
      return 'buyer'; // In sent requests, current user is the buyer
    }
  }

  // Check if current user has rated the other user (seller or buyer)
  bool get sellerAlreadyRated {
    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      // Seller has rated the buyer
      return (buyOrder?.buyerRating != null && buyOrder!.buyerRating! > 0);
    } else {
      // Buyer has rated the seller
      return (buyOrder?.sellerRating != null && buyOrder!.sellerRating! > 0);
    }
  }

  // Check if current user has rated delivery
  bool get deliveryAlreadyRated {
    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      return (buyOrder?.sellerDeliveryRating != null &&
          buyOrder!.sellerDeliveryRating! > 0);
    } else {
      return (buyOrder?.buyerDeliveryRating != null &&
          buyOrder!.buyerDeliveryRating! > 0);
    }
  }

  // Get current user's delivery rating
  int get currentUserDeliveryRating {
    if (currentUserRole == 'buyer') {
      return buyOrder?.buyerDeliveryRating ?? 0;
    } else {
      return buyOrder?.sellerDeliveryRating ?? 0;
    }
  }

  // Get current user's delivery comment
  String get currentUserDeliveryComment {
    if (currentUserRole == 'buyer') {
      return buyOrder?.buyerDeliveryComment ?? '';
    } else {
      return buyOrder?.sellerDeliveryComment ?? '';
    }
  }

  // Get current user's rating of the other user
  int get currentUserOtherRating {
    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      return buyOrder?.buyerRating ?? 0; // Seller's rating of buyer
    } else {
      return buyOrder?.sellerRating ?? 0; // Buyer's rating of seller
    }
  }

  // Get current user's comment about the other user
  String get currentUserOtherComment {
    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      return buyOrder?.buyerComment ?? ''; // Seller's comment about buyer
    } else {
      return buyOrder?.sellerComment ?? ''; // Buyer's comment about seller
    }
  }

  List<Address> adresses = [];
  List<String> deliverymethods = ["Hand Delivery", "Home Delivery"];
  List<String> paymentmethods = ["Cash", "Wallet"];

  Address? address;
  String? deliverymethod;
  String? paymentmethod;

  Selectaddress(value) {
    address = value;
    notifyListeners();
  }

  Selectdeliverymethod(value) {
    deliverymethod = value;
    notifyListeners();
  }

  Selectpaymentmethod(value) {
    paymentmethod = value;
    notifyListeners();
  }

  Future<Either<Failure, bool>> AllAddress(BuildContext context) async {
    adresses.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.Address(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          adresses.add(new Address.fromJson(v));
        });
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  GlobalKey<FormState> keyform = GlobalKey<FormState>();
  List<ProductFull> products = [];
  String? next;
  bool isLoadingMore = false;
  bool isLoadingInitial = false;

  Future<void> RefreshData(BuildContext context) async {
    products.clear();
    next = null;
    MyProducts(context);
  }

  Future<Either<Failure, bool>> MyProducts(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path:
            next ??
            AppApi.Products(
              Provider.of<ServicesProvider>(context, listen: false).userid,
            ),
        pageination: next != null,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        next = json["next"];
        for (var element in json['results']) {
          products.add(ProductFull.fromJson(element));
        }
        notifyListeners();
        log(products.length.toString());
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  Future<Either<Failure, bool>> UpdateBuy(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.UpdateBuy(idbuy!),
        requestType: RequestType.PUT,
        body: jsonEncode({
          "payment_method": paymentmethod,
          "delivery_type": deliverymethod,
          "id_address": address!.id!,
        }),
      );
      var responseBody = response.body;

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        caseController!.ListSentBuy(context);
        return Right(true);
      } else if (response.statusCode == 400) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  Future<Either<Failure, bool>> CanceleBuy(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.CanceleBuy(idbuy!),
        requestType: RequestType.PUT,
      );
      var responseBody = response.body;

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        caseController!.ListSentBuy(context);
        return Right(true);
      } else if (response.statusCode == 400) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  // Process Buy Request (for incoming requests)
  Future<Either<Failure, bool>> ProcessBuyRequest(
    BuildContext context,
    String action,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ProcessBuyRequest(idbuy!),
        requestType: RequestType.POST,
        body: jsonEncode({"action": action}),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);

        // If accepted, try to extract order information
        if (action == "accept" && json.containsKey('order')) {
          try {
            buyOrder = BuyOrder.fromJson(json['order']);
            log('[ProcessBuyRequest] Order created: ${buyOrder?.orderId}');
          } catch (e) {
            log('[ProcessBuyRequest] Failed to parse order from response: $e');
          }
        }

        // Refresh the incoming requests list
        if (incomingRequestsController != null) {
          await incomingRequestsController!.ListReceivedBuy(context);
        }

        // Fetch updated order details
        await fetchOrderDetails(context);

        return Right(true);
      } else if (response.statusCode == 400) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else {
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  void setSellerRating(int value) {
    sellerRating = value;
    notifyListeners();
  }

  void setSellerComment(String value) {
    sellerComment = value;
    notifyListeners();
  }

  void setDeliveryRating(int value) {
    deliveryRating = value;
    notifyListeners();
  }

  void setDeliveryComment(String value) {
    deliveryComment = value;
    notifyListeners();
  }

  // Initialize rating state from order data
  void _initializeRatingState() {
    if (buyOrder != null) {
      final currentRole = currentUserRole;

      // Initialize seller/buyer rating state
      if (currentRole == 'seller') {
        // Seller rates the buyer
        if (buyOrder!.buyerRating != null && buyOrder!.buyerRating! > 0) {
          sellerRating = buyOrder!.buyerRating!;
          sellerComment = buyOrder!.buyerComment ?? '';
          sellerRatingSubmitted = true;
        } else {
          sellerRating = 0;
          sellerComment = '';
          sellerRatingSubmitted = false;
        }
      } else {
        // Buyer rates the seller
        if (buyOrder!.sellerRating != null && buyOrder!.sellerRating! > 0) {
          sellerRating = buyOrder!.sellerRating!;
          sellerComment = buyOrder!.sellerComment ?? '';
          sellerRatingSubmitted = true;
        } else {
          sellerRating = 0;
          sellerComment = '';
          sellerRatingSubmitted = false;
        }
      }

      // Initialize delivery rating state
      if (currentRole == 'seller') {
        if (buyOrder!.sellerDeliveryRating != null &&
            buyOrder!.sellerDeliveryRating! > 0) {
          deliveryRating = buyOrder!.sellerDeliveryRating!;
          deliveryComment = buyOrder!.sellerDeliveryComment ?? '';
          deliveryRatingSubmitted = true;
          currentRaterType = 'seller';
        } else {
          deliveryRating = 0;
          deliveryComment = '';
          deliveryRatingSubmitted = false;
          currentRaterType = null;
        }
      } else {
        if (buyOrder!.buyerDeliveryRating != null &&
            buyOrder!.buyerDeliveryRating! > 0) {
          deliveryRating = buyOrder!.buyerDeliveryRating!;
          deliveryComment = buyOrder!.buyerDeliveryComment ?? '';
          deliveryRatingSubmitted = true;
          currentRaterType = 'buyer';
        } else {
          deliveryRating = 0;
          deliveryComment = '';
          deliveryRatingSubmitted = false;
          currentRaterType = null;
        }
      }
    }
  }

  Future<void> submitSellerRating(BuildContext context) async {
    if (sellerRating == 0) {
      CustomDialog.DialogError(context, title: 'Please select a rating');
      return;
    }

    if (sellerRatingSubmitted) {
      CustomDialog.DialogError(context, title: 'Rating already submitted');
      return;
    }

    final client = Provider.of<NetworkClient>(context, listen: false);
    final currentRole = currentUserRole;

    try {
      final response = await client.request(
        path:
            currentRole == 'seller'
                ? AppApi.RateBuyOrderBuyer(
                  buyOrder!.orderId!,
                ) // Seller rates the buyer
                : AppApi.RateBuyOrderSeller(
                  buyOrder!.orderId!,
                ), // Buyer rates the seller
        requestType: RequestType.PUT,
        body: jsonEncode({
          currentRole == 'seller' ? 'buyer_rating' : 'seller_rating':
              sellerRating,
          currentRole == 'seller' ? 'buyer_comment' : 'seller_comment':
              sellerComment,
        }),
      );

      log('[submitSellerRating] Response status: ${response.statusCode}');
      log('[submitSellerRating] Response body: ${response.body}');

      if (response.statusCode == 200) {
        sellerRatingSubmitted = true;
        if (buyOrder != null) {
          if (currentRole == 'seller') {
            buyOrder!.buyerRating = sellerRating;
            buyOrder!.buyerComment = sellerComment;
          } else {
            buyOrder!.sellerRating = sellerRating;
            buyOrder!.sellerComment = sellerComment;
          }
        }
        notifyListeners();
        CustomDialog.DialogSuccess(context, title: 'User rated successfully');
      } else {
        final json = jsonDecode(response.body);
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Failed to rate user',
        );
      }
    } catch (e) {
      log('[submitSellerRating] Error: $e');
      CustomDialog.DialogError(context, title: 'Error: $e');
    }
  }

  Future<void> submitDeliveryRating(BuildContext context) async {
    if (deliveryRating == 0) {
      CustomDialog.DialogError(context, title: 'Please select a rating');
      return;
    }

    if (deliveryRatingSubmitted) {
      CustomDialog.DialogError(context, title: 'Rating already submitted');
      return;
    }

    final client = Provider.of<NetworkClient>(context, listen: false);
    final raterType = currentUserRole;

    try {
      final response = await client.request(
        path: AppApi.RateBuyOrderDelivery(buyOrder!.orderId!),
        requestType: RequestType.PUT,
        body: jsonEncode({
          'delivery_rating': deliveryRating,
          'delivery_comment': deliveryComment,
          'rater_type': raterType,
        }),
      );

      log('[submitDeliveryRating] Response status: ${response.statusCode}');
      log('[submitDeliveryRating] Response body: ${response.body}');

      if (response.statusCode == 200) {
        deliveryRatingSubmitted = true;
        currentRaterType = raterType;
        if (buyOrder != null) {
          if (raterType == 'buyer') {
            buyOrder!.buyerDeliveryRating = deliveryRating;
            buyOrder!.buyerDeliveryComment = deliveryComment;
          } else {
            buyOrder!.sellerDeliveryRating = deliveryRating;
            buyOrder!.sellerDeliveryComment = deliveryComment;
          }
        }
        notifyListeners();
        CustomDialog.DialogSuccess(
          context,
          title: 'Delivery rated successfully',
        );
      } else {
        final json = jsonDecode(response.body);
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Failed to rate delivery',
        );
      }
    } catch (e) {
      log('[submitDeliveryRating] Error: $e');
      CustomDialog.DialogError(context, title: 'Error: $e');
    }
  }

  /// Returns the buyer's phone number in international format (+9639xxxxxxxx)
  String? getBuyerPhoneInternational() {
    String? phone =
        buymodel?.requester?.user?.phone ??
        buymodel?.productRequested?.buyer?.user?.phone ??
        buyOrder?.buyer?.phone;
    if (phone == null || phone.isEmpty) return null;
    // Remove all non-digit characters
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // If it starts with 0, remove it
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    // Prepend +963
    return '+963$phone';
  }

  Future<void> acceptOrder(BuildContext context) async {
    if (idbuy == null) {
      log('[acceptOrder] idbuy is null, cannot accept order');
      return;
    }

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      log('[acceptOrder] Sending accept order request for idbuy: $idbuy');
      final response = await client.request(
        path: AppApi.ProcessBuyRequest(idbuy!),
        requestType: RequestType.POST,
        body: jsonEncode({"action": "accept"}),
      );

      log('[acceptOrder] Response status: ${response.statusCode}');
      log('[acceptOrder] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.containsKey('order')) {
          buyOrder = BuyOrder.fromJson(json['order']);
          log('[acceptOrder] Order accepted, orderId: ${buyOrder?.orderId}');
        }

        // Fetch updated order details
        await fetchOrderDetails(context);
        CustomDialog.DialogSuccess(
          context,
          title: 'Order accepted successfully',
        );
      } else {
        final json = jsonDecode(response.body);
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Failed to accept order',
        );
      }
    } catch (e) {
      log('[acceptOrder] Error: $e');
      CustomDialog.DialogError(context, title: 'Error: $e');
    }
    notifyListeners();
  }
}
