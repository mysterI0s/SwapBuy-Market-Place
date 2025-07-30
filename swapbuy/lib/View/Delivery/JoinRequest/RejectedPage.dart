import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/View/Delivery/JoinRequest/Controller/JoinRequestController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Widgets/Dropdown/DropdownCustom.dart';
import 'package:swapbuy/Widgets/TextInput/TextInputCustom.dart';

class RejectedPage extends StatelessWidget {
  String? decsription;
  RejectedPage(this.decsription, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JoinRequestController>(
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
                  Gap(20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Your application was rejected for the following reason(s):",
                      textAlign: TextAlign.center,
                      style: TextStyles.title,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        decsription!,
                        textAlign: TextAlign.center,
                        style: TextStyles.paraghraph,
                      ),
                    ),
                  ),
                  Gap(23),
                  Text(
                    "Request info",
                    style: TextStyles.pramed.copyWith(color: AppColors.basic),
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

                  DropdownCustom<String>(
                    isrequierd: true,
                    hint: "City",
                    value: controller.City,
                    items:
                        controller.cities
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (p0) {
                      controller.SelectCity(p0);
                    },
                  ),

                  Gap(22),

                  TextInputCustom(
                    isrequierd: true,
                    hint: "Identity Number",
                    controller: controller.identity_number,
                  ),

                  Gap(22),

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

                  Gap(51),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      onTap: () async {
                        if (controller.keyform.currentState!.validate()) {
                          EasyLoading.show();
                          try {
                            final res = await controller.DeliveryUpdateRequest(
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
                      title: "Update Request",
                      color: AppColors.thirdy,
                    ),
                  ),
                  Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      color: AppColors.red,
                      onTap: () async {
                        EasyLoading.show();
                        try {
                          final res = await controller.DeliveryDeleteRequest(
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
                      },
                      child: Text(
                        "Delete Request",
                        style: TextStyles.button.copyWith(
                          color: AppColors.basic,
                        ),
                      ),
                    ),
                  ),
                  Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: ButtonCustom(
                      color: AppColors.secondery,
                      child: Text(
                        "Back to sign in",
                        style: TextStyles.button.copyWith(
                          color: AppColors.thirdy,
                        ),
                      ),
                      onTap: () {
                        CustomRoute.RoutePop(context);
                      },
                    ),
                  ),
                  Gap(20),
                ],
              ),
            ),
          ),
    );
  }
}
