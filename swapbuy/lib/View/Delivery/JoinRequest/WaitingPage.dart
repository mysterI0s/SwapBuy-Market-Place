import 'package:flutter/material.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Services/Routes.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';

class Waiting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                textAlign: TextAlign.center,
                "Your request is currently being processed,\n Please check the order later ...",
                style: TextStyles.subheader.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: ButtonCustom(
              title: "Back to sign in",
              onTap: () {
                CustomRoute.RoutePop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
