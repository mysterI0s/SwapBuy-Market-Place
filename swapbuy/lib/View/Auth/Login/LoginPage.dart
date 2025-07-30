import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/Auth/ForgetPasswordOrUsername/Controller/ForgetPasswordOrUsernameController.dart';
import 'package:swapbuy/View/Auth/ForgetPasswordOrUsername/ForgetPasswordOrUsername.dart';
import 'package:swapbuy/View/Auth/Login/Controller/LoginPageController.dart';
import 'package:swapbuy/View/Auth/Signup/Controller/SignupController.dart';
import 'package:swapbuy/View/Auth/Signup/Signup.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Loginpagecontroller>(
      builder:
          (context, controller, child) => Scaffold(
            backgroundColor: AppColors.primary,
            body: Form(
              key: controller.keyform,
              child: ListView(
                padding: EdgeInsets.all(8),
                children: [
                  Gap(160),
                  Center(
                    child: Text(
                      "Swapbuy",
                      style: TextStyles.header.copyWith(fontSize: 35.sp),
                    ),
                  ),
                  Gap(90),

                  Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Gap(20),
                  TextInputCustom(
                    controller: controller.usernaem,
                    hint: "Username",
                    isrequierd: true,
                  ),
                  Gap(19),
                  TextInputCustom(
                    controller: controller.password,
                    hint: "Password",
                    ispassword: true,
                    isrequierd: true,
                  ),
                  Gap(16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forget your password?",
                        style: TextStyles.smallpra.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.basic,
                        ),
                      ),
                      Gap(5),
                      GestureDetector(
                        onTap:
                            () => CustomRoute.RouteTo(
                              context,
                              ChangeNotifierProvider(
                                create:
                                    (context) =>
                                        ForgetPasswordOrUsernameController(),
                                builder:
                                    (context, child) =>
                                        ForgetPasswordOrUsername(),
                              ),
                            ),
                        child: Text(
                          "Click here",
                          style: TextStyles.smallpra.copyWith(
                            fontSize: 10.sp,
                            color: Color(0xff999999),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(85),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      onTap: () async {
                        if (controller.keyform.currentState!.validate()) {
                          EasyLoading.show();
                          try {
                            final res = await controller.Login(context);
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
                      title: "Sign in",
                      color: AppColors.thirdy,
                    ),
                  ),
                  Gap(20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
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
                                create:
                                    (context) =>
                                        SignupController()..CITIES(context),
                                builder: (context, child) => Signup(),
                              ),
                            ),
                        child: Text(
                          "Sign up",
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
