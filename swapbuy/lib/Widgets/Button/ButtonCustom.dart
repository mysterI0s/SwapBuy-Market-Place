import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';

class ButtonCustom extends StatelessWidget {
  final String title;
  final Widget? child;
  final VoidCallback onTap;
  final double height;
  double? width;
  final Color color;
  Color? bordercolor;
  double? bordersize;
  double borderradius;

  final bool fullWidth;
  final bool fullheight;

  ButtonCustom({
    this.title = '',
    required this.onTap,
    this.child,
    this.width,
    this.bordercolor,
    this.bordersize,
    this.height = 53,
    this.color = AppColors.thirdy,
    this.fullWidth = true,
    this.fullheight = false,
    this.borderradius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: fullheight ? null : height.h,
        width: fullWidth ? double.infinity : width,
        decoration: BoxDecoration(
          border:
              bordersize != null
                  ? Border.all(width: bordersize!, color: bordercolor!)
                  : null,
          color: color,
          borderRadius: BorderRadius.circular(borderradius),
        ),
        alignment: Alignment.center,
        child: title == '' ? child : Text(title, style: TextStyles.button),
      ),
    );
  }
}
