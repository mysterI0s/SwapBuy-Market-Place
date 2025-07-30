import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';

class WishlistController with ChangeNotifier {
  List<ProductFull> products = [];
  bool isloadingaddwishlist = false;

  Future<Either<Failure, bool>> ProductsWishList(BuildContext context) async {
    products.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.ProductsWishList(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (json.containsKey('products')) {
          for (var element in json['products']) {
            products.add(ProductFull.fromJson(element));
          }
        }

        notifyListeners();

        //CustomDialog.DialogSuccess(context, title: json['message']);
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

  Future<Either<Failure, bool>> RemoveProductWishList(
    BuildContext context,
    int id,
  ) async {
    isloadingaddwishlist = true;
    notifyListeners();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.RemoveProductWishList(
          Provider.of<ServicesProvider>(context, listen: false).userid,
          id,
        ),
        requestType: RequestType.DELETE,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        isloadingaddwishlist = false;
        notifyListeners();
        ProductsWishList(context);
        CustomDialog.DialogSuccess(context, title: json['message']);
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isloadingaddwishlist = false;
        notifyListeners();
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        isloadingaddwishlist = false;
        notifyListeners();

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['error']);
        isloadingaddwishlist = false;
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      isloadingaddwishlist = false;
      notifyListeners();
      log(e.toString());
      return Left(GlobalFailure());
    }
  }
}
