import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/ProfileDelivery.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';

class JoinRequestController with ChangeNotifier {
  GlobalKey<FormState> keyform = GlobalKey<FormState>();
  TextEditingController fullname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  String? gender;
  TextEditingController bod = TextEditingController();

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

  TextEditingController identity_number = TextEditingController();
  TextEditingController address = TextEditingController();
  String? City;
  Future<Either<Failure, bool>> DeliveryUpdateRequest(
    BuildContext context,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.DeliveryUpdateRequest(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.PUT,
        body: jsonEncode({
          "user": {
            "name": fullname.text,
            "gender": gender,
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

      if (response.statusCode == 200) {
        // CustomRoute.RouteReplacementTo(
        //   context,
        //   ChangeNotifierProvider(
        //     create: (context) => Loginpagecontroller(),
        //     lazy: true,
        //     builder: (context, child) => Loginpage(),
        //   ),
        // );
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

  Future<Either<Failure, bool>> DeliveryDeleteRequest(
    BuildContext context,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.DeliveryDeleteRequest(
          Provider.of<ServicesProvider>(context, listen: false).id_request,
        ),
        requestType: RequestType.DELETE,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        CustomRoute.RoutePop(context);
        return Right(true);
      } else if (response.statusCode == 404) {
        if (json.containsKey('error')) {
          CustomDialog.DialogError(context, title: "${json['error']}");
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

  FillData(ProfileDelivery profiledelivery) {
    fullname.text = profiledelivery.user!.name!;
    gender = profiledelivery.user!.gender!;
    email.text = profiledelivery.user!.email!;
    phone.text = profiledelivery.user!.phone!;
    bod.text = profiledelivery.birthDate!;
    identity_number.text = profiledelivery.identity_number!;
    City = profiledelivery.city!;
    address.text = profiledelivery.address!;
    notifyListeners();
  }
}
