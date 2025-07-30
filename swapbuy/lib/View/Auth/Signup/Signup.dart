import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Failure.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/Auth/Login/Controller/LoginPageController.dart';
import 'package:swapbuy/View/Auth/Login/LoginPage.dart';
import 'package:swapbuy/View/Auth/Signup/Controller/SignupController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupController>(
      builder:
          (context, controller, child) => Scaffold(
            backgroundColor: AppColors.primary,
            body: Form(
              key: controller.keyform,
              child: ListView(
                padding: EdgeInsets.all(8),
                children: [
                  Gap(94),
                  Center(
                    child: Text(
                      "Swapbuy",
                      style: TextStyles.header.copyWith(fontSize: 35.sp),
                    ),
                  ),
                  Gap(23),
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Gap(20),
                  TextInputCustom(
                    hint: "Full name",
                    isrequierd: true,
                    controller: controller.fullname,
                  ),
                  Gap(22),
                  TextInputCustom(
                    hint: "Username",
                    isrequierd: true,

                    controller: controller.usernaem,
                  ),
                  Gap(22),
                  TextInputCustom(
                    hint: "Email address",
                    isrequierd: true,

                    controller: controller.email,
                  ),
                  Gap(22),
                  TextInputCustom(
                    isrequierd: true,
                    hint: "Phone number",
                    controller: controller.phone,
                  ),

                  Gap(22),
                  DropdownCustom<String>(
                    isrequierd: true,

                    hint: "Role",
                    value: controller.role,
                    items: [
                      DropdownMenuItem(value: 'user', child: Text("User")),
                      DropdownMenuItem(
                        value: 'delivery',
                        child: Text("Delivery"),
                      ),
                    ],
                    onChanged: (p0) {
                      controller.SelectRole(p0);
                    },
                  ),
                  Gap(22),
                  DropdownCustom<String>(
                    isrequierd: true,

                    hint: "Gender",
                    value: controller.gender,
                    items: [
                      DropdownMenuItem(value: 'Male', child: Text("Male")),
                      DropdownMenuItem(value: 'Female', child: Text("Female")),
                    ],
                    onChanged: (p0) {
                      controller.SelectGender(p0);
                    },
                  ),
                  if (controller.role == 'delivery') Gap(22),
                  if (controller.role == 'delivery')
                    DropdownCustom<String>(
                      isrequierd: true,
                      hint: "City",
                      value: controller.City,
                      items:
                          controller.cities
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (p0) {
                        controller.SelectCity(p0);
                      },
                    ),

                  if (controller.role == 'delivery') Gap(22),
                  if (controller.role == 'delivery')
                    TextInputCustom(
                      isrequierd: true,
                      hint: "Identity Number",
                      controller: controller.identity_number,
                    ),

                  if (controller.role == 'delivery') Gap(22),
                  if (controller.role == 'delivery')
                    TextInputCustom(
                      isrequierd: true,
                      hint: "Address",
                      controller: controller.address,
                    ),

                  Gap(22),
                  TextInputCustom(
                    isrequierd: true,
                    controller: controller.bod,
                    hint: "Birth of date",
                    suffix: GestureDetector(
                      onTap: () {
                        controller.PickBirthday(context);
                      },
                      child: SvgPicture.asset(
                        'assets/SVG/birthday.svg',
                        color: AppColors.white.withAlpha(150),
                        width: 22,
                      ),
                    ),
                  ),
                  Gap(22),
                  TextInputCustom(
                    isrequierd: true,
                    hint: "Password",
                    ispassword: true,
                    controller: controller.password,
                  ),
                  Gap(22),
                  TextInputCustom(
                    controller: controller.confirmpassword,
                    hint: "Confirm Password",
                    isrequierd: true,
                    ispassword: true,
                    validator: (p0) {
                      if (controller.confirmpassword.text !=
                          controller.password.text) {
                        return 'The passwords do not match.';
                      }
                      return null;
                    },
                  ),

                  Gap(51),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      onTap: () async {
                        if (controller.keyform.currentState!.validate()) {
                          EasyLoading.show();
                          try {
                            late Either<Failure, bool> res;
                            if (controller.role == 'delivery')
                              res = await controller.SignupDelivery(context);
                            else
                              res = await controller.Signup(context);

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
                      title: "Sign up",
                      color: AppColors.thirdy,
                    ),
                  ),
                  Gap(20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyles.smallpra.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.basic,
                        ),
                      ),
                      Gap(5),
                      GestureDetector(
                        onTap:
                            () => CustomRoute.RouteReplacementTo(
                              context,
                              ChangeNotifierProvider(
                                create: (context) => Loginpagecontroller(),
                                builder: (context, child) => Loginpage(),
                              ),
                            ),
                        child: Text(
                          "Sign in",
                          style: TextStyles.smallpra.copyWith(
                            fontSize: 12.sp,
                            color: Color(0xff999999),
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
}
