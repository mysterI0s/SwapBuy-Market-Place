import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/Auth/Login/Controller/LoginPageController.dart';
import 'package:swapbuy/View/Auth/Login/LoginPage.dart';

class SignupController with ChangeNotifier {
  GlobalKey<FormState> keyform = GlobalKey<FormState>();
  TextEditingController fullname = TextEditingController();
  TextEditingController usernaem = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  String? role;
  String? gender;
  TextEditingController bod = TextEditingController();

  SelectRole(value) {
    role = value;
    if (value == 'user') {
      address.clear();
      City = null;
      identity_number.clear();
    }
    notifyListeners();
  }

  SelectGender(value) {
    gender = value;
    notifyListeners();
  }

  SelectBod(value) {
    bod.text = value;
    notifyListeners();
  }

  PickBirthday(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime(DateTime.now().year),
    ).then((value) {
      SelectBod(DateFormat('yyyy-MM-dd').format(value!).toString());
    });
  }

  Future<Either<Failure, bool>> Signup(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.REGISTER,
        requestType: RequestType.POST,
        body: jsonEncode({
          "user": {
            "name": fullname.text,
            "gender": gender,
            "username": usernaem.text,
            "password": password.text,
            "email": email.text,
            "phone": phone.text,
          },
          "birth_date": bod.text,
        }),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 201) {
        CustomRoute.RouteReplacementTo(
          context,
          ChangeNotifierProvider(
            create: (context) => Loginpagecontroller(),
            lazy: true,
            builder: (context, child) => Loginpage(),
          ),
        );
        CustomDialog.DialogSuccess(context, title: json['message']);
        return Right(true);
      } else if (response.statusCode == 400) {
        if (json.containsKey('user')) {
          var userErrors = json['user'];

          if (userErrors.containsKey('username') &&
              userErrors['username'] != null) {
            CustomDialog.DialogError(context, title: userErrors['username'][0]);
          }

          if (userErrors.containsKey('email') && userErrors['email'] != null) {
            CustomDialog.DialogError(context, title: userErrors['email'][0]);
          }

          if (userErrors.containsKey('phone') && userErrors['phone'] != null) {
            CustomDialog.DialogError(context, title: userErrors['phone'][0]);
          }

          if (userErrors.containsKey('password') &&
              userErrors['password'] != null) {
            CustomDialog.DialogError(context, title: userErrors['password'][0]);
          }
        }

        if (json.containsKey('birth_date') && json['birth_date'] != null) {
          CustomDialog.DialogError(context, title: json['birth_date'][0]);
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: json['message']);
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  TextEditingController identity_number = TextEditingController();
  TextEditingController address = TextEditingController();
  String? City;
  Future<Either<Failure, bool>> SignupDelivery(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.REGISTERDelivery,
        requestType: RequestType.POST,
        body: jsonEncode({
          "user": {
            "name": fullname.text,
            "gender": gender,
            "username": usernaem.text,
            "password": password.text,
            "email": email.text,
            "phone": phone.text,
          },
          "birth_date": bod.text,
          "identity_number": identity_number.text,
          "city": City,
          "address": address.text,
        }),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 201) {
        CustomRoute.RouteReplacementTo(
          context,
          ChangeNotifierProvider(
            create: (context) => Loginpagecontroller(),
            lazy: true,
            builder: (context, child) => Loginpage(),
          ),
        );
        CustomDialog.DialogSuccess(context, title: json['message']);
        return Right(true);
      } else if (response.statusCode == 400) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: "${json['details'][0]}");
        }

        return Right(false);
      } else {
        CustomDialog.DialogError(context, title: "Error");
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  List<String> cities = [];
  Future<Either<Failure, bool>> CITIES(BuildContext context) async {
    cities.clear();
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.CITIES,
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        json.forEach((v) {
          cities.add(v);
        });
        notifyListeners();
        // CustomDialog.DialogSuccess(context, title: json['message']);
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

  SelectCity(value) {
    City = value;
    notifyListeners();
  }
}
