import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/ProfileDelivery.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/HomePageDeliveryController.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/DeliveryOrderController.dart';
import 'package:swapbuy/View/Delivery/Home/HomePageDelivery.dart';
import 'package:swapbuy/View/Delivery/JoinRequest/Controller/JoinRequestController.dart';
import 'package:swapbuy/View/Delivery/JoinRequest/RejectedPage.dart';
import 'package:swapbuy/View/Delivery/JoinRequest/WaitingPage.dart';
import 'package:swapbuy/View/User/Navigation/Controller/NavigationPageUserController.dart';
import 'package:swapbuy/View/User/Navigation/NavigationPageUser.dart';

class Loginpagecontroller with ChangeNotifier {
  GlobalKey<FormState> keyform = GlobalKey<FormState>();
  TextEditingController usernaem = TextEditingController();
  TextEditingController password = TextEditingController();
  Future<Either<Failure, bool>> Login(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.LOGIN,
        requestType: RequestType.POST,
        body: jsonEncode({
          "username": usernaem.text,
          "password": password.text,
        }),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (json['role'] == 'UserApplication') {
          await context.read<ServicesProvider>().saveUserIDAndRole(
            json['user_application_id'],
            json['role'],
          );
          final userIdForChat = json['user_application_data']['user']['id'];
          await context.read<ServicesProvider>().saveUserIdForChat(
            userIdForChat,
          );
          CustomRoute.RouteReplacementTo(
            context,
            ChangeNotifierProvider(
              create: (context) => NavigationPageUserController(),
              lazy: true,
              builder: (context, child) => NavigationPageUser(),
            ),
          );
        }

        if (json['role'] == 'Delivery') {
          if (json['join_request']['status'] == null) {
            CustomRoute.RouteTo(context, Waiting());
          } else if (!json['join_request']['status']) {
            await context.read<ServicesProvider>().saveDeliveryIDAndRole(
              json['delivery_id'],
              json['join_request']['id'],
              json['role'],
              false,
            );
            ProfileDelivery profileDelivery = ProfileDelivery.fromJson(json);
            CustomRoute.RouteTo(
              context,
              ChangeNotifierProvider(
                create:
                    (context) =>
                        JoinRequestController()
                          ..CITIES(context)
                          ..FillData(profileDelivery),
                lazy: true,
                builder:
                    (context, child) =>
                        RejectedPage(json['join_request']['description']),
              ),
            );
          } else if (json['join_request']['status']) {
            await context.read<ServicesProvider>().saveDeliveryIDAndRole(
              json['delivery_id'],
              json['join_request']['id'],
              json['role'],
              true,
            );
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
            CustomDialog.DialogSuccess(context, title: json['message']);
          }
        }

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
