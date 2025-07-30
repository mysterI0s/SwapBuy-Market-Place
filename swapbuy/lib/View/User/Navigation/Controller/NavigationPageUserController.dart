import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/View/User/AddProduct/AddProduct.dart';
import 'package:swapbuy/View/User/AddProduct/Controller/AddProductController.dart';
import 'package:swapbuy/View/User/AllAddress/AllAddress.dart';
import 'package:swapbuy/View/User/AllAddress/Controller/AllAddressController.dart';
import 'package:swapbuy/View/User/Home/Controller/HomePageUserController.dart';
import 'package:swapbuy/View/User/Home/HomePageUser.dart';
import 'package:swapbuy/View/User/MyProduct/Controller/MyProductController.dart';
import 'package:swapbuy/View/User/MyProduct/MyProduct.dart';
import 'package:swapbuy/View/User/Settings/SettingsPageUser.dart';

class NavigationPageUserController with ChangeNotifier {
  int index = 4;

  List<Widget> pages = [
    SettingsPageUser(),
    ChangeNotifierProvider(
      create: (context) => MyProductController()..MyProducts(context),
      builder: (context, child) => Myproduct(),
    ),
    ChangeNotifierProvider(
      create:
          (context) =>
              AddProductController()
                ..STATUSOPTIONS(context)
                ..CONDITIONOPTIONS(context)
                ..AllAddress(context),
      builder: (context, child) => Addproduct(),
    ),
    ChangeNotifierProvider(
      create:
          (context) =>
              AllAddressController()
                ..AllAddress(context)
                ..CITIES(context),
      builder: (context, child) => AllAddress(),
    ),
    ChangeNotifierProvider(
      create: (context) => HomePageUserController()..AllProduct(context),
      builder: (context, child) => Homepageuser(),
    ),
  ];
  ChangeIndex(int value) {
    index = value;
    notifyListeners();
  }
}
