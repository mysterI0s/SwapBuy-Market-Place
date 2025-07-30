import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/ProductFull.dart';
// import 'package:swapbuy/Model/ProductModel.dart';
import 'package:swapbuy/Services/NetworkClient.dart';

class HomePageUserController with ChangeNotifier {
  List<ProductFull> products = [];
  String? next;
  bool isLoadingMore = false;
  bool isLoadingInitial = false;

  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  String? selectedStatus;
  String? selectedCondition;
  String? selectedCity;
  String? selectedOrderBy;

  List<String> availableCondition = [
    'Brand New',
    'Like New',
    "Good Condition",
    "Fair Condition",
    "Poor Condition",
  ];
  List<String> availableStatuses = ['Available', 'Not Available'];
  List<String> availableCities = [
    'Damascus',
    'Aleppo',
    'Homs',
    'Latakia',
    'Tartus',
    'Daraa',
    'Deir Ezzor',
  ];
  List<Map<String, String>> orderByOptions = [
    {'display': 'Added: Oldest First', 'value': 'added_oldest'},
    {'display': 'Added: Newest First', 'value': 'added_newest'},
    {'display': 'Price: Low to High', 'value': 'price_low_high'},
    {'display': 'Price: High to Low', 'value': 'price_high_low'},
  ];

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Selectors
  void SelectCondition(String? value) {
    selectedCondition = value;
    if (!_disposed) notifyListeners();
  }

  void SelectStatus(String? value) {
    selectedStatus = value;
    if (!_disposed) notifyListeners();
  }

  void SelectOrderBy(String? value) {
    selectedOrderBy = value;
    if (!_disposed) notifyListeners();
  }

  void SelectCity(String? value) {
    selectedCity = value;
    if (!_disposed) notifyListeners();
  }

  void applyFilters({BuildContext? context}) {
    products.clear();
    next = null;
    FilterProduct(context);
    if (!_disposed) notifyListeners();
  }

  void resetAllFilters(BuildContext context) {
    minPriceController.clear();
    maxPriceController.clear();
    selectedCondition = null;
    selectedStatus = null;
    selectedCity = null;
    selectedOrderBy = null;
    AllProduct(context);
    if (!_disposed) notifyListeners();
  }

  Future<void> RefreshData(BuildContext context) async {
    products.clear();
    next = null;

    bool hasFilters =
        minPriceController.text.isNotEmpty ||
        maxPriceController.text.isNotEmpty ||
        selectedCondition != null ||
        selectedStatus != null ||
        selectedCity != null ||
        selectedOrderBy != null;

    if (hasFilters) {
      await FilterProduct(context);
    } else {
      await AllProduct(context);
    }
  }

  Future<void> AllProduct(BuildContext? context) async {
    if (isLoadingMore || isLoadingInitial) return;

    if (products.isEmpty && next == null) {
      isLoadingInitial = true;
    } else {
      isLoadingMore = true;
    }
    if (!_disposed) notifyListeners();

    final client =
        context != null
            ? Provider.of<NetworkClient>(context, listen: false)
            : null;
    if (client == null) {
      _resetLoadingStates();
      log("NetworkClient not available in HomePageUserController.");
      return;
    }

    try {
      final response = await client.request(
        path: next ?? AppApi.AllProduct,
        pageination: next != null,
        requestType: RequestType.GET,
      );

      _handleResponse(response, context);
    } catch (e) {
      _handleError(e, context);
    } finally {
      _resetLoadingStates();
    }
  }

  Future<void> FilterProduct(BuildContext? context) async {
    if (isLoadingMore || isLoadingInitial) return;

    if (products.isEmpty && next == null) {
      isLoadingInitial = true;
    } else {
      isLoadingMore = true;
    }
    if (!_disposed) notifyListeners();

    final client =
        context != null
            ? Provider.of<NetworkClient>(context, listen: false)
            : null;
    if (client == null) {
      _resetLoadingStates();
      log("NetworkClient not available in HomePageUserController.");
      return;
    }

    Map<String, dynamic> queryParams = {};
    if (minPriceController.text.isNotEmpty)
      queryParams['min_price'] = minPriceController.text;
    if (maxPriceController.text.isNotEmpty)
      queryParams['max_price'] = maxPriceController.text;
    if (selectedCondition != null)
      queryParams['condition'] = selectedCondition!;
    if (selectedStatus != null) queryParams['status'] = selectedStatus!;
    if (selectedCity != null) queryParams['city'] = selectedCity!;
    if (selectedOrderBy != null) queryParams['order_by'] = selectedOrderBy!;

    Uri uri = Uri.parse("${AppApi.url}/Service/products/filter/");
    uri = uri.replace(queryParameters: queryParams);

    try {
      final response = await client.request(
        path: next ?? uri.toString(),
        pageination: true,
        requestType: RequestType.GET,
      );

      _handleResponse(response, context);
    } catch (e) {
      _handleError(e, context);
    } finally {
      _resetLoadingStates();
    }
  }

  void _handleResponse(response, BuildContext? context) {
    log(response.statusCode.toString());
    log(response.body);

    final json = jsonDecode(response.body);
    if (json is Map && json.containsKey('results')) {
      next = json["next"];
      for (var element in json['results']) {
        products.add(ProductFull.fromJson(element));
      }
    } else if (json is List) {
      for (var element in json) {
        products.add(ProductFull.fromJson(element));
      }
    }
    if (!_disposed) notifyListeners();
    _resetLoadingStates();
  }

  void _handleError(dynamic e, BuildContext? context) {
    log(e.toString());
    if (!_disposed) notifyListeners();
    _resetLoadingStates();
  }

  void _resetLoadingStates() {
    isLoadingInitial = false;
    isLoadingMore = false;
    if (!_disposed) notifyListeners();
  }
}
