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
import 'package:swapbuy/Model/Profile.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/NetworkClient.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:http/http.dart' as http;

import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class ProfileUserController with ChangeNotifier {
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

  ProfileUser profileUser = ProfileUser();
  Future<Either<Failure, bool>> PROFILE(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.PROFILE(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.GET,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        profileUser = ProfileUser.fromJson(json);
        FillData(profileUser);
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

  RemoveImage() {
    image = null;
    notifyListeners();
  }

  Future<Either<Failure, bool>> DeleteImageProfile(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.DeleteImageProfile(
          Provider.of<ServicesProvider>(context, listen: false).userid,
        ),
        requestType: RequestType.DELETE,
      );

      log(response.statusCode.toString());
      log(response.body);
      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        PROFILE(context);
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

  Future<Either<Failure, bool>> UPDATEPROFILE(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      List<http.MultipartFile> files = [];

      if (image != null) {
        files.add(
          await http.MultipartFile.fromPath('user.profile_image', image!.path),
        );
      }
      var response = await client.requestwithmultifile(
        path: AppApi.UPDATEPROFILE(
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

  FillData(ProfileUser profileUser) {
    profileImage = null;
    fullname.text = profileUser.user!.name!;
    usernaem.text = profileUser.user!.username!;
    email.text = profileUser.user!.email!;
    phone.text = profileUser.user!.phone!;
    gender = profileUser.user!.gender!;
    bod.text = profileUser.birthDate!;
    if (profileUser.user!.profileImage != null) {
      profileImage = profileUser.user!.profileImage!;
    }
    notifyListeners();
  }

  TextEditingController oldpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();

  Future<Either<Failure, bool>> UPDATEPASSWORD(BuildContext context) async {
    final client = Provider.of<NetworkClient>(context, listen: false);
    try {
      var response = await client.request(
        path: AppApi.UPDATEPASSWORD(
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
                                final res = await UPDATEPASSWORD(context);
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
