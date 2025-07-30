import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';

class CartBuyPageController with ChangeNotifier {
  ProductFull? productFull;

  initstate(ProductFull productFull) {
    this.productFull = productFull;
    notifyListeners();
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

  Future<Either<Failure, bool>> RequestSwap(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.RequestBuy(
          Provider.of<ServicesProvider>(context, listen: false).userid,
          productFull!.product!.id!,
        ),
        requestType: RequestType.POST,
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

      if (response.statusCode == 201) {
        CustomDialog.DialogSuccess(context, title: json['message']);

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
}
