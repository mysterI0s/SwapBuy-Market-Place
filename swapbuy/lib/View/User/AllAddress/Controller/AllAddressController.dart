import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/Address.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class AllAddressController with ChangeNotifier {
  GlobalKey<FormState> keyform = GlobalKey<FormState>();
  TextEditingController street = TextEditingController();
  TextEditingController neighborhood = TextEditingController();
  TextEditingController building_number = TextEditingController();
  String? city;
  TextEditingController description = TextEditingController();
  TextEditingController postal_code = TextEditingController();
  TextEditingController country = TextEditingController();
  List<String> cities = [];
  List<Address> adresses = [];
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
    city = value;
    notifyListeners();
  }

  DialogAddAddress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Form(
            key: keyform,
            child: AlertDialog(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text("Add Address", style: TextStyles.title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextInputCustom(
                      hint: "Street",
                      controller: street,
                      isrequierd: true,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Neighborhood",
                      controller: neighborhood,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Building number",
                      controller: building_number,
                    ),
                    Gap(10),
                    DropdownCustom<String>(
                      onChanged: (p0) => SelectCity(p0),
                      hint: "City",
                      value: city,
                      items:
                          cities
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      isrequierd: true,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Description",
                      controller: description,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Postal code",
                      controller: postal_code,
                      isrequierd: true,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Country",
                      controller: country,
                      isrequierd: true,
                    ),
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                              (states) => AppColors.secondery,
                            ),
                          ),
                          onPressed: () async {
                            if (keyform.currentState!.validate()) {
                              EasyLoading.show();
                              try {
                                final res = await AddAddress(context);
                                res.fold(
                                  (l) {
                                    EasyLoading.showError(l.message);
                                    EasyLoading.dismiss();
                                  },
                                  (r) {
                                    EasyLoading.dismiss();
                                  },
                                );
                              } catch (e) {
                                EasyLoading.dismiss();
                              }
                            }
                          },
                          child: Text(
                            "Add",
                            style: TextStyles.button.copyWith(
                              color: AppColors.thirdy,
                            ),
                          ),
                        ),
                        TextButton(
                          child: Text(
                            "Close",
                            style: TextStyles.pramed.copyWith(
                              color: AppColors.forth,
                            ),
                          ),
                          onPressed: () {
                            CustomRoute.RoutePop(context);
                            ClearData();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  DialogEditAddress(BuildContext context, Address address) async {
    await FillData(address);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => Form(
            key: keyform,
            child: AlertDialog(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text("Edit Address", style: TextStyles.title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextInputCustom(
                      hint: "Street",
                      controller: street,
                      isrequierd: true,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Neighborhood",
                      controller: neighborhood,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Building number",
                      controller: building_number,
                    ),
                    Gap(10),
                    DropdownCustom<String>(
                      onChanged: (p0) => SelectCity(p0),
                      hint: "City",
                      value: city,
                      items:
                          cities
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      isrequierd: true,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Description",
                      controller: description,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Postal code",
                      controller: postal_code,
                      isrequierd: true,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "Country",
                      controller: country,
                      isrequierd: true,
                    ),
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                              (states) => AppColors.secondery,
                            ),
                          ),
                          onPressed: () async {
                            if (keyform.currentState!.validate()) {
                              EasyLoading.show();
                              try {
                                final res = await EditAddress(
                                  context,
                                  address.id!,
                                );
                                res.fold(
                                  (l) {
                                    EasyLoading.showError(l.message);
                                    EasyLoading.dismiss();
                                  },
                                  (r) {
                                    EasyLoading.dismiss();
                                  },
                                );
                              } catch (e) {
                                EasyLoading.dismiss();
                              }
                            }
                          },
                          child: Text(
                            "Edit",
                            style: TextStyles.button.copyWith(
                              color: AppColors.thirdy,
                            ),
                          ),
                        ),
                        TextButton(
                          child: Text(
                            "Close",
                            style: TextStyles.pramed.copyWith(
                              color: AppColors.forth,
                            ),
                          ),
                          onPressed: () {
                            CustomRoute.RoutePop(context);
                            ClearData();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  DialogDeleteAddress(BuildContext context, Address address) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.basic,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Do you really want to Delete this Address ?",
                    style: TextStyles.title.copyWith(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ButtonCustom(
                          color: Color(0x80DE2427),
                          borderradius: 100,
                          bordercolor: Color(0xff700002),
                          bordersize: 1,
                          height: 40,
                          onTap: () async {
                            EasyLoading.show();
                            try {
                              final res = await DeleteAddress(
                                context,
                                address.id!,
                              );
                              res.fold(
                                (l) {
                                  EasyLoading.showError(l.message);
                                  EasyLoading.dismiss();
                                },
                                (r) {
                                  EasyLoading.dismiss();
                                },
                              );
                            } catch (e) {
                              EasyLoading.dismiss();
                            }
                          },
                          child: Text(
                            "Delete",
                            style: TextStyles.button.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      Gap(5),
                      Expanded(
                        child: ButtonCustom(
                          borderradius: 100,
                          height: 40,
                          bordersize: 1,

                          bordercolor: AppColors.black,
                          color: AppColors.secondery,
                          onTap: () async {
                            CustomRoute.RoutePop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyles.button.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<Either<Failure, bool>> AddAddress(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.AddAddress(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.POST,
        body: jsonEncode({
          "street": street.text,
          "neighborhood": neighborhood.text,
          "building_number": building_number.text,
          "city": city,
          "description": description.text,
          "postal_code": postal_code.text,
          "country": country.text,
        }),
      );
      var responseBody = response.body;

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        AllAddress(context);
        CustomRoute.RoutePop(context);
        ClearData();
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

  Future<Either<Failure, bool>> EditAddress(
    BuildContext context,
    int id,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.EditAddress(id),
        requestType: RequestType.PUT,
        body: jsonEncode({
          "street": street.text,
          "neighborhood": neighborhood.text,
          "building_number": building_number.text,
          "city": city,
          "description": description.text,
          "postal_code": postal_code.text,
          "country": country.text,
        }),
      );
      var responseBody = response.body;

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
        AllAddress(context);
        CustomRoute.RoutePop(context);
        ClearData();
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

  Future<Either<Failure, bool>> DeleteAddress(
    BuildContext context,
    int id,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.DeleteAddress(id),
        requestType: RequestType.DELETE,
      );

      log(response.statusCode.toString());
      log(response.body);
      // Only decode if body is not empty
      var hasBody = response.body.trim().isNotEmpty;
      var json = hasBody ? jsonDecode(response.body) : null;

      if (response.statusCode == 204) {
        await AllAddress(context);
        notifyListeners();
        CustomRoute.RoutePop(context);
        return Right(true);
      } else if (response.statusCode == 400) {
        if (json != null && json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else if (response.statusCode == 401) {
        if (json != null && json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        }
        return Right(false);
      } else {
        if (json != null && json.containsKey('error')) {
          CustomDialog.DialogError(context, title: json['error']);
        } else {
          CustomDialog.DialogError(
            context,
            title: 'An unexpected error occurred',
          );
        }
        return Right(false);
      }
    } catch (e) {
      log(e.toString());
      return Left(GlobalFailure());
    }
  }

  FillData(Address address) {
    street.text = address.street!;
    neighborhood.text = address.neighborhood!;
    city = address.city!;
    country.text = address.country!;
    description.text = address.description!;
    postal_code.text = address.postalCode!;
    building_number.text = address.buildingNumber!;
  }

  ClearData() {
    street.clear();
    neighborhood.clear();
    city = null;
    country.clear();
    description.clear();
    postal_code.clear();
    building_number.clear();
    notifyListeners();
  }
}
