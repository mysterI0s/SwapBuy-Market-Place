import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/BuyOrder.dart';
import 'package:swapbuy/Model/SwapOrder.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Delivery/Home/OrderDetailsScreen.dart';

class DeliveryOrderController with ChangeNotifier {
  // Fetch a single order by ID (swap or buy)
  Future<dynamic> fetchOrderById(
    BuildContext context,
    int orderId,
    String type,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    final path =
        type == 'swap'
            ? AppApi.SwapOrderDetail(orderId)
            : AppApi.BuyOrderDetail(orderId);
    final response = await client.request(
      path: path,
      requestType: RequestType.GET,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (type == 'swap') {
        final swapOrder = SwapOrder.fromJson(data);
        // If ratings missing, fetch swap-request details and inject ratings
        if ((swapOrder.buyerDeliveryRating == null ||
                swapOrder.sellerDeliveryRating == null) &&
            swapOrder.swapRequestId != null) {
          final swapRequestPath =
              '/Service/api/swap-requests/${swapOrder.swapRequestId}/detail/';
          final swapReqResp = await client.request(
            path: swapRequestPath,
            requestType: RequestType.GET,
          );
          if (swapReqResp.statusCode == 200) {
            final swapReqData = json.decode(swapReqResp.body);
            // Try to get ratings from swapReqData['order']['ratings']
            final orderObj = swapReqData['order'];
            final ratings =
                (orderObj != null && orderObj['ratings'] != null)
                    ? orderObj['ratings']
                    : (swapReqData['ratings'] ?? swapReqData);
            swapOrder.buyerDeliveryRating ??=
                ratings['delivery_rating_by_buyer'];
            swapOrder.buyerDeliveryComment ??=
                ratings['delivery_comment_by_buyer'];
            swapOrder.sellerDeliveryRating ??=
                ratings['delivery_rating_by_seller'];
            swapOrder.sellerDeliveryComment ??=
                ratings['delivery_comment_by_seller'];
            swapOrder.sellerRating ??= ratings['seller_rating'];
            swapOrder.sellerComment ??= ratings['seller_comment'];
            swapOrder.buyerRating ??= ratings['buyer_rating'];
            swapOrder.buyerComment ??= ratings['buyer_comment'];
          }
        }
        return swapOrder;
      } else {
        return BuyOrder.fromJson(data);
      }
    }
    throw Exception('Failed to fetch order');
  }

  List<SwapOrder> availableSwapOrders = [];
  List<BuyOrder> availableBuyOrders = [];
  List<SwapOrder> mySwapOrders = [];
  List<BuyOrder> myBuyOrders = [];
  List<SwapOrder> acceptedSwapOrders = [];
  List<BuyOrder> acceptedBuyOrders = [];
  List<SwapOrder> deliveredSwapOrders = [];
  List<BuyOrder> deliveredBuyOrders = [];
  List<String> orderStatusOptions = [];

  bool isLoading = false;

  // Get available orders for delivery
  Future<Either<Failure, bool>> getAvailableSwapOrders(
    BuildContext context,
  ) async {
    availableSwapOrders.clear();
    isLoading = true;
    notifyListeners();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.AvailableSwapOrdersForDelivery,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          availableSwapOrders.add(SwapOrder.fromJson(v));
        });
        isLoading = false;
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isLoading = false;
        notifyListeners();
        return Right(false);
      } else {
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        isLoading = false;
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
      return Left(GlobalFailure());
    }
  }

  Future<Either<Failure, bool>> getAvailableBuyOrders(
    BuildContext context,
  ) async {
    availableBuyOrders.clear();
    isLoading = true;
    notifyListeners();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.AvailableBuyOrdersForDelivery,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          availableBuyOrders.add(BuyOrder.fromJson(v));
        });
        isLoading = false;
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isLoading = false;
        notifyListeners();
        return Right(false);
      } else {
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        isLoading = false;
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
      return Left(GlobalFailure());
    }
  }

  // Accept/Reject Swap Order
  Future<Either<Failure, bool>> acceptSwapOrder(
    BuildContext context,
    int orderId,
    int deliveryId,
    String action,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.AcceptSwapOrder(orderId, deliveryId),
        requestType: RequestType.POST,
        body: jsonEncode({"action": action}),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        // Refresh available orders
        await getAvailableSwapOrders(context);
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

  // Accept/Reject Buy Order
  Future<Either<Failure, bool>> acceptBuyOrder(
    BuildContext context,
    int orderId,
    int deliveryId,
    String action,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.AcceptBuyOrder(orderId, deliveryId),
        requestType: RequestType.POST,
        body: jsonEncode({"action": action}),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        // Refresh available orders
        await getAvailableBuyOrders(context);
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

  // Get my orders (assigned to delivery person)
  Future<Either<Failure, bool>> getMySwapOrders(
    BuildContext context,
    int deliveryId,
  ) async {
    mySwapOrders.clear();
    isLoading = true;
    notifyListeners();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.SwapOrdersForDelivery(deliveryId),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          mySwapOrders.add(SwapOrder.fromJson(v));
        });
        isLoading = false;
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isLoading = false;
        notifyListeners();
        return Right(false);
      } else {
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        isLoading = false;
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
      return Left(GlobalFailure());
    }
  }

  Future<Either<Failure, bool>> getMyBuyOrders(
    BuildContext context,
    int deliveryId,
  ) async {
    myBuyOrders.clear();
    isLoading = true;
    notifyListeners();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.BuyOrdersForDelivery(deliveryId),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          myBuyOrders.add(BuyOrder.fromJson(v));
        });
        isLoading = false;
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isLoading = false;
        notifyListeners();
        return Right(false);
      } else {
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        isLoading = false;
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
      return Left(GlobalFailure());
    }
  }

  // Update Swap Order Status
  Future<Either<Failure, bool>> updateSwapOrderStatus(
    BuildContext context,
    int orderId,
    String newStatus,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.UpdateSwapOrderStatus(orderId),
        requestType: RequestType.PUT,
        body: jsonEncode({"order_status": newStatus}),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        // Refresh both my orders lists
        final deliveryId =
            Provider.of<ServicesProvider>(context, listen: false).deliveryId;
        if (deliveryId != null) {
          await getMySwapOrders(context, deliveryId);
          await getMyBuyOrders(context, deliveryId);
        }
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

  // Update Buy Order Status
  Future<Either<Failure, bool>> updateBuyOrderStatus(
    BuildContext context,
    int orderId,
    String newStatus,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.UpdateBuyOrderStatus(orderId),
        requestType: RequestType.PUT,
        body: jsonEncode({"order_status": newStatus}),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        // Refresh both my orders lists
        final deliveryId =
            Provider.of<ServicesProvider>(context, listen: false).deliveryId;
        if (deliveryId != null) {
          await getMySwapOrders(context, deliveryId);
          await getMyBuyOrders(context, deliveryId);
        }
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

  // Get order status options
  Future<Either<Failure, bool>> getOrderStatusOptions(
    BuildContext context,
  ) async {
    orderStatusOptions.clear();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.SwapOrderStatusOptions,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        orderStatusOptions = List<String>.from(json);
        notifyListeners();
        return Right(true);
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

  // Get accepted orders
  Future<Either<Failure, bool>> getAcceptedOrders(
    BuildContext context,
    int deliveryId,
  ) async {
    acceptedSwapOrders.clear();
    acceptedBuyOrders.clear();
    isLoading = true;
    notifyListeners();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.AcceptedOrdersForDelivery(deliveryId),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (json['swap_orders'] != null) {
          json['swap_orders'].forEach((v) {
            acceptedSwapOrders.add(SwapOrder.fromJson(v));
          });
        }
        if (json['buy_orders'] != null) {
          json['buy_orders'].forEach((v) {
            acceptedBuyOrders.add(BuyOrder.fromJson(v));
          });
        }
        isLoading = false;
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isLoading = false;
        notifyListeners();
        return Right(false);
      } else {
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        isLoading = false;
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
      return Left(GlobalFailure());
    }
  }

  // Get delivered orders
  Future<Either<Failure, bool>> getDeliveredOrders(
    BuildContext context,
    int deliveryId,
  ) async {
    deliveredSwapOrders.clear();
    deliveredBuyOrders.clear();
    isLoading = true;
    notifyListeners();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.DeliveredOrdersForDelivery(deliveryId),
        requestType: RequestType.GET,
      );

      log('Delivered Orders API Response Status: ${response.statusCode}');
      log('Delivered Orders API Response Body: ${response.body}');
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // The backend returns a flat array, so we need to iterate through it
        if (json is List) {
          for (var orderData in json) {
            if (orderData['request_type'] == 'Swap') {
              deliveredSwapOrders.add(SwapOrder.fromJson(orderData));
            } else if (orderData['request_type'] == 'Buy') {
              // For buy orders, we need to map the products structure
              var buyOrderData = Map<String, dynamic>.from(orderData);
              if (buyOrderData['products'] != null &&
                  buyOrderData['products']['requested'] != null) {
                buyOrderData['product'] = buyOrderData['products']['requested'];
              }
              deliveredBuyOrders.add(BuyOrder.fromJson(buyOrderData));
            }
          }
        }
        isLoading = false;
        notifyListeners();
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isLoading = false;
        notifyListeners();
        return Right(false);
      } else {
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        isLoading = false;
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
      return Left(GlobalFailure());
    }
  }

  // View order details
  void viewOrderDetails(BuildContext context, dynamic order, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    fetchOrderById(context, order.orderId, type)
        .then((latestOrder) {
          Navigator.pop(context); // Remove loading dialog
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      OrderDetailsScreen(order: latestOrder, orderType: type),
            ),
          );
        })
        .catchError((e) {
          Navigator.pop(context);
          CustomDialog.DialogError(
            context,
            title: 'Failed to load order details',
          );
        });
  }

  // Update order status
  Future<Either<Failure, bool>> updateOrderStatus(
    BuildContext context,
    int orderId,
    String newStatus,
    String type,
  ) async {
    try {
      bool success = false;

      if (type == 'swap') {
        final result = await updateSwapOrderStatus(context, orderId, newStatus);
        success = result.fold((failure) => false, (result) => result);
      } else {
        final result = await updateBuyOrderStatus(context, orderId, newStatus);
        success = result.fold((failure) => false, (result) => result);
      }

      if (success) {
        CustomDialog.DialogSuccess(
          context,
          title: 'Status updated successfully',
        );
        // Refresh the orders list
        final deliveryId =
            Provider.of<ServicesProvider>(context, listen: false).deliveryId;
        if (deliveryId != null) {
          await getMySwapOrders(context, deliveryId);
          await getMyBuyOrders(context, deliveryId);
        }
        return Right(true);
      } else {
        CustomDialog.DialogError(context, title: 'Failed to update status');
        return Right(false);
      }
    } catch (e) {
      CustomDialog.DialogError(context, title: 'Error updating status: $e');
      return Right(false);
    }
  }
}
