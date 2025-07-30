import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/BuyModel.dart';
import 'package:swapbuy/Model/SwapModel.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';

class IncomingRequestsController with ChangeNotifier {
  List<SwapModel> swaprequests = [];
  List<BuyModel> buyrequests = [];
  List<String> oredertype = ['added_newest', 'added_oldest'];
  String selectedoredertype = 'added_newest';
  Future<Either<Failure, bool>> ListReceivedSwap(BuildContext context) async {
    swaprequests.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ListReceivedSwap(
          Provider.of<ServicesProvider>(context, listen: false).userid,
          selectedoredertype,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json['received_swaps'].forEach((v) {
          swaprequests.add(new SwapModel.fromJson(v));
        });
        // CustomDialog.DialogSuccess(context, title: json['message']);

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

  Future<Either<Failure, bool>> ListReceivedBuy(BuildContext context) async {
    buyrequests.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ListReceivedBuy(
          Provider.of<ServicesProvider>(context, listen: false).userid,
          selectedoredertype,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json['received_buy_requests'].forEach((v) {
          buyrequests.add(new BuyModel.fromJson(v));
        });
        // CustomDialog.DialogSuccess(context, title: json['message']);

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

  // Process Swap Request
  Future<Either<Failure, bool>> ProcessSwapRequest(
    BuildContext context,
    int swapRequestId,
    String action,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ProcessSwapRequest(swapRequestId),
        requestType: RequestType.POST,
        body: jsonEncode({"action": action}),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        // Refresh the list after processing
        await ListReceivedSwap(context);
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

  // Process Buy Request
  Future<Either<Failure, bool>> ProcessBuyRequest(
    BuildContext context,
    int buyRequestId,
    String action,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ProcessBuyRequest(buyRequestId),
        requestType: RequestType.POST,
        body: jsonEncode({"action": action}),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        // Refresh the list after processing
        await ListReceivedBuy(context);
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

  // Remove swap request from list
  void removeSwapRequest(int index, BuildContext context) {
    if (index >= 0 && index < swaprequests.length) {
      // If the request is pending, automatically reject it
      if (swaprequests[index].swapRequest!.status == "Pending") {
        // Use the existing ProcessSwapRequest function
        ProcessSwapRequest(
          context,
          swaprequests[index].swapRequest!.id!,
          "reject",
        );
      }
      // Remove from local list
      swaprequests.removeAt(index);
      notifyListeners();
    }
  }

  // Remove buy request from list
  void removeBuyRequest(int index, BuildContext context) {
    if (index >= 0 && index < buyrequests.length) {
      // If the request is pending, automatically reject it
      if (buyrequests[index].buyRequest!.status == "Pending") {
        // Use the existing ProcessBuyRequest function
        ProcessBuyRequest(
          context,
          buyrequests[index].buyRequest!.id!,
          "reject",
        );
      }
      // Remove from local list
      buyrequests.removeAt(index);
      notifyListeners();
    }
  }
}
