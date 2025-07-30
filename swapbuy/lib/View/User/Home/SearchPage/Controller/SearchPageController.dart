import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/ProductFull.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';

class SearchPageController with ChangeNotifier {
  List<ProductFull> results = [];
  String? next;
  bool isLoading = false;
  String currentQuery = '';

  Future<void> resetSearch() async {
    results.clear();
    next = null;
    currentQuery = '';
    notifyListeners();
  }

  Future<Either<Failure, bool>> searchProducts(
    String query,
    BuildContext context,
  ) async {
    if (isLoading) return Right(false);
    isLoading = true;
    notifyListeners();

    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: next ?? AppApi.SearchProduct(query),
        pageination: next != null,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        next = json["next"];
        for (var element in json['results']) {
          results.add(ProductFull.fromJson(element));
        }
        currentQuery = query;
        isLoading = false;
        notifyListeners();
        return Right(true);
      } else {
        isLoading = false;
        CustomDialog.DialogError(
          context,
          title: json['error'] ?? 'Unknown error',
        );
        notifyListeners();
        return Right(false);
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      log(e.toString());
      return Left(GlobalFailure());
    }
  }
}
