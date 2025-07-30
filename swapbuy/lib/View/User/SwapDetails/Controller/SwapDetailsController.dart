import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Model/SwapModel.dart';
import 'package:swapbuy/Model/SwapOrder.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/User/AcceptanceCase/Controller/AcceptanceCaseController.dart';
import 'package:swapbuy/View/User/IncomingRequests/Controller/IncomingRequestsController.dart';

class SwapDetailsController with ChangeNotifier {
  ProductOffered? productrequest;
  ProductOffered? productoffered;
  int? idswap;
  SwapModel? swapmodel;
  SwapOrder? swapOrder;
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

  Map<String, dynamic>? rawSwapDetails;

  initstate(
    BuildContext context,
    SwapModel swapmodel, {
    AcceptanceCaseController? caseController,
    IncomingRequestsController? incomingRequestsController,
  }) async {
    await AllAddress(context);
    this.swapmodel = swapmodel;
    this.caseController = caseController;
    this.incomingRequestsController = incomingRequestsController;
    idswap = swapmodel.swapRequest!.id!;
    productrequest = swapmodel.productRequested;
    productoffered = swapmodel.productOffered;

    if (incomingRequestsController == null) {
      address =
          adresses
              .where((element) => element.id == swapmodel.selectedAddress!.id!)
              .first;
    }
    deliverymethod = swapmodel.swapRequest!.deliveryType!;
    paymentmethod = swapmodel.swapRequest!.paymentMethod!;

    // Fetch order details to get order status for rating functionality
    await fetchOrderDetails(context);
    notifyListeners();
  }

  // Use swap request endpoint which includes order details
  Future<void> fetchOrderDetails(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);

    if (idswap == null) {
      log('[fetchOrderDetails] idswap is null, cannot fetch swap request.');
      return;
    }

    try {
      log('[fetchOrderDetails] Fetching swap request for idswap: $idswap');
      final swapRequestResponse = await client.request(
        path: '/Service/api/swap-requests/$idswap/detail/',
        requestType: RequestType.GET,
      );
      log(
        '[fetchOrderDetails] SwapRequest response status: ${swapRequestResponse.statusCode}',
      );
      log(
        '[fetchOrderDetails] SwapRequest response body: ${swapRequestResponse.body}',
      );

      if (swapRequestResponse.statusCode == 200) {
        final swapRequestData = jsonDecode(swapRequestResponse.body);
        rawSwapDetails = swapRequestData;
        log('[fetchOrderDetails] $rawSwapDetails');

        // Parse the response which contains swap_request, order, and products
        if (swapRequestData.containsKey('order') &&
            swapRequestData['order'] != null) {
          log('[fetchOrderDetails] Found order in swap request data');
          log(
            '[fetchOrderDetails] Full order data: ${jsonEncode(swapRequestData['order'])}',
          );
          swapOrder = SwapOrder.fromJson(swapRequestData['order']);
          log(
            '[fetchOrderDetails] Parsed order status: ${swapOrder?.orderStatus}',
          );
          log('[fetchOrderDetails] Can rate order: $canRateOrder');
        } else {
          // If we didn't find order at top level, this might be the old response format
          // where order is nested inside swap_request
          if (swapRequestData.containsKey('swap_request')) {
            final swapRequest = swapRequestData['swap_request'];
            if (swapRequest != null && swapRequest.containsKey('order')) {
              swapOrder = SwapOrder.fromJson(swapRequest['order']);
            }
          }
        }

        if (swapOrder != null) {
          log('[fetchOrderDetails] Using order data from swap request');
          log(
            '[fetchOrderDetails] Order status: ${swapOrder?.orderStatus}, Status: ${swapOrder?.status}',
          );
          log('[fetchOrderDetails] Can rate order: $canRateOrder');
          _initializeRatingState();
        } else {
          log(
            '[fetchOrderDetails] No order associated with this swap request yet.',
          );
          swapOrder = null;
        }
      } else {
        log(
          '[fetchOrderDetails] Failed to fetch swap request: ${swapRequestResponse.statusCode}',
        );
        swapOrder = null;
      }
    } catch (e) {
      log('[fetchOrderDetails] Error fetching swap request: $e');
      swapOrder = null;
    }
    notifyListeners();
  }

  // FIXED: Check if order is delivered and can be rated
  bool get canRateOrder {
    log('[canRateOrder] Checking if order can be rated...');
    log('[canRateOrder] swapmodel status: ${swapmodel?.swapRequest?.status}');

    // Check if swap request is accepted first
    final swapStatus = swapmodel?.swapRequest?.status?.toLowerCase();
    if (swapStatus != 'accepted') {
      log('[canRateOrder] Swap not accepted yet. Status: $swapStatus');
      return false;
    }

    if (swapOrder == null) {
      log(
        '[canRateOrder] No order found, but swap is accepted - allowing rating',
      );
      return true; // Allow rating if swap is accepted even without order details
    }

    final orderStatus = swapOrder?.orderStatus?.toLowerCase();
    log('[canRateOrder] Checking order status: $orderStatus');

    // The order must have a "Delivered" status to be ratable, or if no order status, allow if swap is accepted
    if (orderStatus == null || orderStatus.isEmpty) {
      log(
        '[canRateOrder] No order status, but swap is accepted - allowing rating',
      );
      return true;
    }

    if (orderStatus == 'delivered' || orderStatus == 'completed') {
      log('[canRateOrder] Order is delivered/completed and can be rated');
      return true;
    }

    log('[canRateOrder] Order cannot be rated yet. Status: $orderStatus');
    return false;
  }

  // Determine current user's role in the order
  String get currentUserRole {
    if (incomingRequestsController != null) {
      return 'seller'; // In incoming requests, current user is the seller
    } else {
      return 'buyer'; // In sent requests, current user is the buyer
    }
  }

  // FIXED: Check if current user has rated the other user (seller or buyer)
  bool get sellerAlreadyRated {
    if (swapOrder == null) return sellerRatingSubmitted;

    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      // Seller has rated the buyer
      return (swapOrder?.buyerRating != null && swapOrder!.buyerRating! > 0) ||
          sellerRatingSubmitted;
    } else {
      // Buyer has rated the seller
      return (swapOrder?.sellerRating != null &&
              swapOrder!.sellerRating! > 0) ||
          sellerRatingSubmitted;
    }
  }

  // FIXED: Check if current user has rated delivery
  bool get deliveryAlreadyRated {
    if (swapOrder == null) return deliveryRatingSubmitted;

    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      return (swapOrder?.sellerDeliveryRating != null &&
              swapOrder!.sellerDeliveryRating! > 0) ||
          deliveryRatingSubmitted;
    } else {
      return (swapOrder?.buyerDeliveryRating != null &&
              swapOrder!.buyerDeliveryRating! > 0) ||
          deliveryRatingSubmitted;
    }
  }

  // Get current user's delivery rating
  int get currentUserDeliveryRating {
    if (currentUserRole == 'buyer') {
      return swapOrder?.buyerDeliveryRating ?? deliveryRating;
    } else {
      return swapOrder?.sellerDeliveryRating ?? deliveryRating;
    }
  }

  // Get current user's delivery comment
  String get currentUserDeliveryComment {
    if (currentUserRole == 'buyer') {
      return swapOrder?.buyerDeliveryComment ?? deliveryComment;
    } else {
      return swapOrder?.sellerDeliveryComment ?? deliveryComment;
    }
  }

  // Get current user's rating of the other user
  int get currentUserOtherRating {
    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      return swapOrder?.buyerRating ?? sellerRating; // Seller's rating of buyer
    } else {
      return swapOrder?.sellerRating ??
          sellerRating; // Buyer's rating of seller
    }
  }

  // Get current user's comment about the other user
  String get currentUserOtherComment {
    final currentRole = currentUserRole;
    if (currentRole == 'seller') {
      return swapOrder?.buyerComment ??
          sellerComment; // Seller's comment about buyer
    } else {
      return swapOrder?.sellerComment ??
          sellerComment; // Buyer's comment about seller
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

  Future<Either<Failure, bool>> UpdateSwap(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.UpdateSwap(idswap!),
        requestType: RequestType.PUT,
        body: jsonEncode({
          "product_offered": productoffered!.product!.id!,
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
        caseController!.ListSentSwap(context);
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

  Future<Either<Failure, bool>> CanceleSwap(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.CanceleSwap(idswap!),
        requestType: RequestType.PUT,
      );
      var responseBody = response.body;

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        caseController!.ListSentSwap(context);
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

  // Process Swap Request (for incoming requests)
  Future<Either<Failure, bool>> ProcessSwapRequest(
    BuildContext context,
    String action,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ProcessSwapRequest(idswap!),
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
            swapOrder = SwapOrder.fromJson(json['order']);
            log('[ProcessSwapRequest] Order created: ${swapOrder?.orderId}');
          } catch (e) {
            log('[ProcessSwapRequest] Failed to parse order from response: $e');
          }
        }

        // Update the swap model status
        if (swapmodel?.swapRequest != null) {
          if (action == "accept") {
            swapmodel!.swapRequest!.status = "Accepted";
          } else if (action == "reject") {
            swapmodel!.swapRequest!.status = "Rejected";
          }
        }

        // Refresh the incoming requests list
        if (incomingRequestsController != null) {
          await incomingRequestsController!.ListReceivedSwap(context);
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

  // FIXED: Initialize rating state from order data
  void _initializeRatingState() {
    log('[_initializeRatingState] Initializing rating state...');
    if (swapOrder != null) {
      log('[_initializeRatingState] Current ratings state:');
      log('Buyer Rating: ${swapOrder?.buyerRating}');
      log('Seller Rating: ${swapOrder?.sellerRating}');
      log('Buyer Delivery Rating: ${swapOrder?.buyerDeliveryRating}');
      log('Seller Delivery Rating: ${swapOrder?.sellerDeliveryRating}');

      final currentRole = currentUserRole;

      // Initialize seller/buyer rating state
      if (currentRole == 'seller') {
        // Seller rates the buyer
        if (swapOrder!.buyerRating != null && swapOrder!.buyerRating! > 0) {
          sellerRating = swapOrder!.buyerRating!;
          sellerComment = swapOrder!.buyerComment ?? '';
          sellerRatingSubmitted = true;
        } else {
          sellerRating = 0;
          sellerComment = '';
          sellerRatingSubmitted = false;
        }
      } else {
        // Buyer rates the seller
        if (swapOrder!.sellerRating != null && swapOrder!.sellerRating! > 0) {
          sellerRating = swapOrder!.sellerRating!;
          sellerComment = swapOrder!.sellerComment ?? '';
          sellerRatingSubmitted = true;
        } else {
          sellerRating = 0;
          sellerComment = '';
          sellerRatingSubmitted = false;
        }
      }

      // Initialize delivery rating state
      if (currentRole == 'seller') {
        if (swapOrder!.sellerDeliveryRating != null &&
            swapOrder!.sellerDeliveryRating! > 0) {
          deliveryRating = swapOrder!.sellerDeliveryRating!;
          deliveryComment = swapOrder!.sellerDeliveryComment ?? '';
          deliveryRatingSubmitted = true;
          currentRaterType = 'seller';
        } else {
          deliveryRating = 0;
          deliveryComment = '';
          deliveryRatingSubmitted = false;
          currentRaterType = null;
        }
      } else {
        if (swapOrder!.buyerDeliveryRating != null &&
            swapOrder!.buyerDeliveryRating! > 0) {
          deliveryRating = swapOrder!.buyerDeliveryRating!;
          deliveryComment = swapOrder!.buyerDeliveryComment ?? '';
          deliveryRatingSubmitted = true;
          currentRaterType = 'buyer';
        } else {
          deliveryRating = 0;
          deliveryComment = '';
          deliveryRatingSubmitted = false;
          currentRaterType = null;
        }
      }
    } else {
      log('[_initializeRatingState] No order data, setting defaults');
      // Set default values when no order data is available
      sellerRating = 0;
      sellerComment = '';
      sellerRatingSubmitted = false;
      deliveryRating = 0;
      deliveryComment = '';
      deliveryRatingSubmitted = false;
      currentRaterType = null;
    }
    log('[_initializeRatingState] Rating state initialized successfully');
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
                ? AppApi.RateSwapOrderBuyer(
                  swapOrder!.orderId!,
                ) // Seller rates the buyer
                : AppApi.RateSwapOrderSeller(
                  swapOrder!.orderId!,
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
        if (swapOrder != null) {
          if (currentRole == 'seller') {
            swapOrder!.buyerRating = sellerRating;
            swapOrder!.buyerComment = sellerComment;
          } else {
            swapOrder!.sellerRating = sellerRating;
            swapOrder!.sellerComment = sellerComment;
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
        path: AppApi.RateSwapOrderDelivery(swapOrder!.orderId!),
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
        if (swapOrder != null) {
          if (raterType == 'buyer') {
            swapOrder!.buyerDeliveryRating = deliveryRating;
            swapOrder!.buyerDeliveryComment = deliveryComment;
          } else {
            swapOrder!.sellerDeliveryRating = deliveryRating;
            swapOrder!.sellerDeliveryComment = deliveryComment;
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
        swapmodel?.requester?.user?.phone ?? swapOrder?.buyer?.phone;
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
    if (idswap == null) {
      log('[acceptOrder] idswap is null, cannot accept order');
      return;
    }

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      log('[acceptOrder] Sending accept order request for idswap: $idswap');
      final response = await client.request(
        path: AppApi.ProcessSwapRequest(idswap!),
        requestType: RequestType.POST,
        body: jsonEncode({"action": "accept"}),
      );

      log('[acceptOrder] Response status: ${response.statusCode}');
      log('[acceptOrder] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.containsKey('order')) {
          swapOrder = SwapOrder.fromJson(json['order']);
          log('[acceptOrder] Order accepted, orderId: ${swapOrder?.orderId}');
        }

        // Update swap status
        if (swapmodel?.swapRequest != null) {
          swapmodel!.swapRequest!.status = "Accepted";
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
