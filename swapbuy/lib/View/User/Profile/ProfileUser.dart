import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Constant/url.dart';
import 'package:swapbuy/View/User/Profile/Controller/ProfileUserController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class Profileuser extends StatelessWidget {
  const Profileuser({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileUserController>(
      builder:
          (context, controller, child) => Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            backgroundColor: AppColors.primary,
            body: Form(
              key: controller.keyform,
              child: ListView(
                padding: EdgeInsets.all(8),
                children: [
                  Gap(12),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 200.w,
                          height: 200.w,
                          decoration: BoxDecoration(
                            color: AppColors.secondery,
                            shape: BoxShape.circle,
                          ),
                          child:
                              controller.image == null
                                  ? controller.profileImage != null
                                      ? ClipOval(
                                        child: FadeInImage.assetNetwork(
                                          image:
                                              "${AppApi.url}${controller.profileImage!}",
                                          placeholder: 'assets/PNG/Logo.png',
                                        ),
                                      )
                                      : Icon(
                                        Icons.person,
                                        color: AppColors.thirdy,
                                      )
                                  : ClipOval(
                                    child: Image.file(
                                      File(controller.image!.path),
                                    ),
                                  ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => controller.PickProfile(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.thirdy,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.edit,
                                  color: AppColors.secondery,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (controller.image != null ||
                            controller.profileImage != null)
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: GestureDetector(
                              onTap:
                                  () =>
                                      controller.image != null
                                          ? controller.RemoveImage()
                                          : controller.DeleteImageProfile(
                                            context,
                                          ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: AppColors.basic,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Gap(10),
                  Center(
                    child: Text(
                      "@${controller.usernaem.text}",
                      style: TextStyles.title,
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
                  Gap(51),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      onTap: () async {
                        if (controller.keyform.currentState!.validate()) {
                          EasyLoading.show();
                          try {
                            final res = await controller.UPDATEPROFILE(context);
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
                      title: "Confirm",
                      color: AppColors.thirdy,
                    ),
                  ),
                  Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      onTap: () async {
                        controller.DialogChangePassword(context);
                      },

                      color: AppColors.secondery,
                      child: Text(
                        "Change Password",
                        style: TextStyles.button.copyWith(
                          color: AppColors.thirdy,
                        ),
                      ),
                    ),
                  ),
                  Gap(20),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Already have an account?",
                  //       style: TextStyles.smallpra.copyWith(
                  //         fontSize: 12.sp,
                  //         color: AppColors.basic,
                  //       ),
                  //     ),
                  //     // Gap(5),
                  //     // GestureDetector(
                  //     //   onTap:
                  //     //       () => CustomRoute.RouteReplacementTo(
                  //     //         context,
                  //     //         ChangeNotifierProvider(
                  //     //           create: (context) => Loginpagecontroller(),
                  //     //           builder: (context, child) => Loginpage(),
                  //     //         ),
                  //     //       ),
                  //     //   child: Text(
                  //     //     "Sign in",
                  //     //     style: TextStyles.smallpra.copyWith(
                  //     //       fontSize: 12.sp,
                  //     //       color: Color(0xff999999),
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
    );
  }
}
