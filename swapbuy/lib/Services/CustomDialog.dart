import 'package:swapbuy/Constant/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:swapbuy/Widgets/SnackBarCustom/SnakBarCustom.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CustomDialog {
  static DialogSuccess(BuildContext context, {String? title}) {
    showTopSnackBar(
      curve: Curves.fastLinearToSlowEaseIn,
      Overlay.of(context),

      CustomSnackBar.success(
        textStyle: TextStyles.title.copyWith(color: Color(0xff00E676)),
        message: title!,
      ),
    );
  }

  static DialogError(BuildContext context, {String? title}) {
    showTopSnackBar(
      curve: Curves.fastLinearToSlowEaseIn,
      Overlay.of(context),
      CustomSnackBar.error(
        textStyle: TextStyles.title.copyWith(color: Color(0xffff5252)),
        message: title!,
      ),
    );
  }

  static DialogWarning(BuildContext context, {String? title}) {
    showTopSnackBar(
      curve: Curves.fastLinearToSlowEaseIn,
      Overlay.of(context),
      CustomSnackBar.info(
        textStyle: TextStyles.title,
        backgroundColor: Colors.orange,
        message: title!,
      ),
    );
  }
}
