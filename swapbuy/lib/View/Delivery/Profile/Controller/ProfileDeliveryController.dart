import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/Model/ProfileDelivery.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:http/http.dart' as http;

import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class ProfileDeliveryController with ChangeNotifier {
  GlobalKey<FormState> keyform = GlobalKey<FormState>();
  GlobalKey<FormState> keyformpassword = GlobalKey<FormState>();
  TextEditingController fullname = TextEditingController();
  TextEditingController usernaem = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  String? gender;
  TextEditingController bod = TextEditingController();
  String? profileImage;
  XFile? image;
  ImagePicker picker = ImagePicker();

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

  RemoveImage() {
    image = null;
    notifyListeners();
  }

  Future<Either<Failure, bool>> DeleteImageProfileDelivery(
    BuildContext context,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.DeleteImageProfileDelivery(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.DELETE,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        PROFILEDelivery(context);
        CustomDialog.DialogSuccess(context, title: json['message']);
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

  TextEditingController identity_number = TextEditingController();
  TextEditingController address = TextEditingController();
  String? City;

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

  ProfileDelivery profileDelivery = ProfileDelivery();
  Future<Either<Failure, bool>> PROFILEDelivery(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.PROFILEDelivery(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        profileDelivery = ProfileDelivery.fromJson(json);
        await FillData(profileDelivery);
        CustomDialog.DialogSuccess(context, title: json['message']);
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

  PickProfile() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  Future<Either<Failure, bool>> UPDATEPROFILEDelivery(
    BuildContext context,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      List<http.MultipartFile> files = [];

      if (image != null) {
        files.add(
          await http.MultipartFile.fromPath('user.profile_image', image!.path),
        );
      }
      var response = await client.requestwithmultifile(
        path: AppApi.UPDATEPROFILEDelivery(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.PUT,
        body: {
          "user.name": fullname.text,
          "user.username": usernaem.text,
          "user.phone": phone.text,
          "user.email": email.text,
          "user.gender": gender!,
          "birth_date": bod.text,
          "identity_number": identity_number.text,
          "city": City!,
          "address": address.text,
        },
        files: files,
      );
      var responseBody = await response.stream.bytesToString();

      log(response.statusCode.toString());
      log(responseBody);
      var json = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(
          context,
          title: "Update Profile Successfuly",
          //  json['message']
        );
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

  FillData(ProfileDelivery profileDelivery) {
    profileImage = null;
    fullname.text = profileDelivery.user!.name!;
    usernaem.text = profileDelivery.user!.username!;
    email.text = profileDelivery.user!.email!;
    phone.text = profileDelivery.user!.phone!;
    gender = profileDelivery.user!.gender!;
    bod.text = profileDelivery.birthDate!;
    City = profileDelivery.city!;
    identity_number.text = profileDelivery.identity_number!;
    address.text = profileDelivery.address!;
    if (profileDelivery.user!.profileImage != null) {
      profileImage = profileDelivery.user!.profileImage!;
    }
    notifyListeners();
  }

  TextEditingController oldpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();

  Future<Either<Failure, bool>> UPDATEPASSWORDDelivery(
    BuildContext context,
  ) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.UPDATEPASSWORDDelivery(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.PUT,
        body: jsonEncode({
          'old_password': oldpassword.text,
          'new_password': newpassword.text,
        }),
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        CustomDialog.DialogSuccess(context, title: json['message']);
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

  DialogChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Form(
            key: keyformpassword,
            child: AlertDialog(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text("Change Password", style: TextStyles.title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextInputCustom(
                      hint: "Old password",
                      ispassword: true,
                      controller: oldpassword,
                    ),
                    Gap(10),
                    TextInputCustom(
                      hint: "New password",
                      ispassword: true,
                      controller: newpassword,
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
                            if (keyformpassword.currentState!.validate()) {
                              EasyLoading.show();
                              try {
                                final res = await UPDATEPASSWORDDelivery(
                                  context,
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
                            "Done",
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
                          onPressed: () => CustomRoute.RoutePop(context),
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
}
