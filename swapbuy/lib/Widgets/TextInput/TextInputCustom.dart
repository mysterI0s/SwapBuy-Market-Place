// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gap/gap.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';

class TextInputCustom extends StatefulWidget {
  Icon? icon;
  Widget? suffix;
  TextInputType? type;
  bool isrequierd = false;
  String? hint;
  bool? ispassword;
  int? line;
  String? Function(String?)? validator;
  bool enable;
  TextEditingController? controller;
  Color? bordercolor;
  Color? fillcolor;
  Color? foucedcolor;

  TextInputCustom({
    this.icon,
    this.type,
    this.controller,
    this.hint,
    this.isrequierd = false,
    this.validator,
    this.ispassword = false,
    this.enable = true,
    this.line = 1,
    this.suffix,
    this.bordercolor = AppColors.border,
    this.fillcolor = AppColors.basic,
  });

  @override
  State<TextInputCustom> createState() => _TextInputCustomState();
}

class _TextInputCustomState extends State<TextInputCustom> {
  bool? visiblepassword = true;

  @override
  Widget build(BuildContext context) {
    return
    // Container(
    // decoration: BoxDecoration(
    //   borderRadius: BorderRadius.circular(20),
    //   boxShadow: [
    //     BoxShadow(
    //       blurRadius: 7,
    //       color: AppColors.black.withAlpha(50),
    //       offset: Offset(0, 3.5),
    //     ),
    //   ],
    // ),
    // child:
    TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      validator:
          widget.validator ??
          (value) {
            if (widget.isrequierd) {
              if (value!.isEmpty || value == '') {
                return widget.isrequierd ? "This field is required" : '';
              }
              return null;
            } else {
              return null;
            }
          },
      maxLines: widget.line,
      keyboardType: widget.type,
      style: TextStyles.inputtitle.copyWith(
        color: widget.fillcolor!,
        fontSize: 14,
      ),
      obscureText: widget.ispassword! ? visiblepassword! : false,
      onTapOutside: (event) => FocusManager.instance.primaryFocus!.unfocus(),
      cursorColor: AppColors.active,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor:
            widget.enable
                ? widget.fillcolor!.withOpacity(.05)
                : AppColors.grey50,

        // prefixIcon: widget.icon,
        suffixIconConstraints: BoxConstraints.expand(width: 40, height: 20),
        suffixIcon:
            widget.ispassword!
                ? visiblepassword!
                    ? GestureDetector(
                      onTap:
                          () => setState(() {
                            visiblepassword = !visiblepassword!;
                          }),
                      child: SvgPicture.asset(
                        'assets/SVG/eye_close.svg',
                        color: AppColors.white.withAlpha(150),
                        width: 22,
                      ),
                    )
                    : GestureDetector(
                      onTap:
                          () => setState(() {
                            visiblepassword = !visiblepassword!;
                          }),
                      child: SvgPicture.asset(
                        'assets/SVG/eye_open.svg',
                        color: AppColors.white.withAlpha(150),
                        width: 22,
                      ),
                    )
                : widget.suffix,
        enabled: widget.enable,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: widget.bordercolor!, width: .5),
        ),
        errorStyle: TextStyles.smallpra.copyWith(
          color: AppColors.redlight,
          fontSize: 10.sp,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: widget.fillcolor!.withAlpha(80),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.redlight, width: .5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: widget.bordercolor!, width: .5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: widget.bordercolor!, width: .5),
        ),
        label: Text(
          widget.hint ?? '',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp),
          softWrap: true,
        ),
        labelStyle: TextStyles.inputtitle.copyWith(
          color: widget.fillcolor!.withAlpha(150),
        ),
        floatingLabelStyle: TextStyles.inputtitle.copyWith(
          color: widget.fillcolor!.withAlpha(150),
        ),
        contentPadding: EdgeInsets.all(20),
      ),
      // ),
    );
  }
}
