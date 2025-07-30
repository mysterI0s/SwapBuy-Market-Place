// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/View/Splash/Controller/SplashController.dart';
import 'package:provider/provider.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SplashController>(
      builder:
          (context, value, child) => Scaffold(
            extendBodyBehindAppBar: true,

            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.basic],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/PNG/Logo.png", width: 170.w),
                        Gap(10.h),
                        Text(
                          "Swapbuy",
                          style: TextStyles.header.copyWith(fontSize: 30.sp),
                        ),
                        Gap(20.h),
                        LoadingAnimationWidget.discreteCircle(
                          color: AppColors.primary,
                          secondRingColor: AppColors.primary,
                          thirdRingColor: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
