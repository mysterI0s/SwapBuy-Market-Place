// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Auth/Login/Controller/LoginPageController.dart';
import 'package:swapbuy/View/Auth/Login/LoginPage.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/HomePageDeliveryController.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/DeliveryOrderController.dart';
import 'package:swapbuy/View/Delivery/Home/HomePageDelivery.dart';
import 'package:swapbuy/View/User/Navigation/Controller/NavigationPageUserController.dart';
import 'package:swapbuy/View/User/Navigation/NavigationPageUser.dart';

class SplashController with ChangeNotifier {
  @override
  dispose() {
    log("close splash");
    super.dispose();
  }

  whenIslogin(BuildContext context) async {
    Future.delayed(Duration(seconds: 5)).then((value) async {
      if (Provider.of<ServicesProvider>(context, listen: false).isLoggedIn) {
        if (Provider.of<ServicesProvider>(context, listen: false).role ==
            'UserApplication') {
          toHomePageUser(context);
        } else {
          toHomePageDelivery(context);
        }
      } else {
        toLoginPage(context);
      }
    });
  }

  toLoginPage(BuildContext context) {
    CustomRoute.RouteReplacementTo(
      context,
      ChangeNotifierProvider<Loginpagecontroller>(
        create: (context) => Loginpagecontroller(),
        child: Loginpage(),
      ),
    );
  }

  toHomePageUser(BuildContext context) {
    CustomRoute.RouteReplacementTo(
      context,
      ChangeNotifierProvider(
        create: (context) => NavigationPageUserController(),
        lazy: true,
        builder: (context, child) => NavigationPageUser(),
      ),
    );
  }

  toHomePageDelivery(BuildContext context) {
    CustomRoute.RouteReplacementTo(
      context,
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => HomePageDeliveryController(),
          ),
          ChangeNotifierProvider(
            create: (context) => DeliveryOrderController(),
          ),
        ],
        child: HomePageDelivery(),
      ),
    );
  }
}
