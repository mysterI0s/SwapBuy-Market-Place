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

class AcceptanceCaseController with ChangeNotifier {
  List<SwapModel> swaprequests = [];
  List<BuyModel> buyrequests = [];
  List<String> oredertype = ['added_newest', 'added_oldest'];
  String selectedoredertype = 'added_newest';
  Future<Either<Failure, bool>> ListSentSwap(BuildContext context) async {
    swaprequests.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ListSentSwap(
          Provider.of<ServicesProvider>(context, listen: false).userid,
          selectedoredertype,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json['sent_swaps'].forEach((v) {
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

  Future<Either<Failure, bool>> ListSentBuy(BuildContext context) async {
    buyrequests.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ListSentBuy(
          Provider.of<ServicesProvider>(context, listen: false).userid,
          selectedoredertype,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json['sent_buy_requests'].forEach((v) {
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
}
