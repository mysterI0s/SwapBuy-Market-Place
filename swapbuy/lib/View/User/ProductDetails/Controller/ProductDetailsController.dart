import 'dart:convert';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';

class ProductDetailsController with ChangeNotifier {
  String getPostedTime(String value) {
    final addedAt = DateTime.parse(value);

    final now = DateTime.now();
    final difference = now.difference(addedAt);

    if (difference.inDays > 0) {
      return "Posted ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "Posted ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else {
      return "Posted just now";
    }
  }

  bool isloadingaddwishlist = false;

  Future<void> AddProductWishList(BuildContext context, int id) async {
    isloadingaddwishlist = true;
    notifyListeners();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.AddProductWishList(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.POST,
        body: jsonEncode({"product_id": id}),
      );
      var responseBody = response.body;

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        isloadingaddwishlist = false;
        notifyListeners();
        CustomDialog.DialogSuccess(context, title: json['message']);
      } else if (response.statusCode == 400) {
        isloadingaddwishlist = false;
        notifyListeners();
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
      } else if (response.statusCode == 401) {
        isloadingaddwishlist = false;
        notifyListeners();
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
      } else {
        isloadingaddwishlist = false;
        notifyListeners();
        CustomDialog.DialogError(context, title: json['error']);
      }
    } catch (e) {
      isloadingaddwishlist = false;
      notifyListeners();
      log(e.toString());
    }
  }
}
