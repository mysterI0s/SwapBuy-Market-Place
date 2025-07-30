import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/View/Auth/ForgetPasswordOrUsername/Controller/ForgetPasswordOrUsernameController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class ForgetPasswordOrUsername extends StatelessWidget {
  const ForgetPasswordOrUsername({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgetPasswordOrUsernameController>(
      builder:
          (context, controller, child) => Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            backgroundColor: AppColors.primary,
            body: Form(
              key: controller.keyform,
              child: ListView(
                padding: EdgeInsets.all(8),
                children: [
                  Gap(85),
                  Center(
                    child: Text(
                      "Swapbuy",
                      style: TextStyles.header.copyWith(fontSize: 35.sp),
                    ),
                  ),
                  Gap(55),
                  Text(
                    "Select Role ",
                    style: TextStyle(
                      color: AppColors.basic,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Gap(10),
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
                  Gap(23),
                  Text(
                    "Forget password or username",
                    style: TextStyle(
                      color: AppColors.basic,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Gap(10),
                  Text(
                    "if you have forgotten your password or username, enter your email address to send link to reset password or username.",
                    style: TextStyle(
                      color: AppColors.basic,

                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Gap(20),
                  TextInputCustom(
                    isrequierd: true,
                    controller: controller.email,
                    hint: "Email address",
                  ),
                  Gap(85),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      onTap: () async {
                        if (controller.keyform.currentState!.validate()) {
                          EasyLoading.show();
                          try {
                            final res = await controller.ResetPassword(context);
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
                      title: "Reset password",
                      color: AppColors.thirdy,
                    ),
                  ),
                  Gap(22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      onTap: () async {
                        if (controller.keyform.currentState!.validate()) {
                          EasyLoading.show();
                          try {
                            final res = await controller.ForgetUsername(
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
                      title: "Reset Username",
                      color: AppColors.thirdy,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
