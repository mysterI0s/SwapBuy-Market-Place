import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/Address.dart';

class DropdownCustom<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final bool enable;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  bool isrequierd = false;
  String? Function(T?)? validator;
  Color? bordercolor;
  Color? fillcolor;
  DropdownCustom({
    required this.items,
    required this.onChanged,
    this.value,
    this.isrequierd = false,
    this.validator,
    this.hint,
    this.enable = true,
    this.bordercolor = AppColors.border,
    this.fillcolor = AppColors.basic,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator:
          validator ??
          (value) {
            if (isrequierd) {
              if (value == null) {
                return isrequierd ? "This field is required" : '';
              }
              return null;
            } else {
              return null;
            }
          },
      value: value,
      items: items,
      selectedItemBuilder: (context) {
        return items.map((item) {
          return item.child is Text
              ? Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  (item.child as Text).data ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyles.paraghraph.copyWith(color: fillcolor),
                ),
              )
              : Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${(item.value as Address).buildingNumber!}${(item.value as Address).buildingNumber != "" ? ',' : ""}${(item.value as Address).street!}${(item.value as Address).street != "" ? ',' : ""}${(item.value as Address).neighborhood!}${(item.value as Address).neighborhood != "" ? ',' : ""}${(item.value as Address).city}${(item.value as Address).city != "" ? ',' : ""}${(item.value as Address).postalCode}${(item.value as Address).postalCode != "" ? ',' : ""}${(item.value as Address).country}",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyles.paraghraph.copyWith(color: fillcolor),
                ),
              );
        }).toList();
      },
      onChanged: enable ? onChanged : null,
      dropdownColor: AppColors.active,
      isExpanded: true,
      style: TextStyles.inputtitle.copyWith(color: fillcolor!, fontSize: 14),
      borderRadius: BorderRadius.circular(15),
      iconEnabledColor: fillcolor!.withAlpha(150),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabled: enable,
        filled: true,
        fillColor: fillcolor!.withOpacity(.05),
        errorStyle: TextStyles.smallpra.copyWith(
          color: AppColors.redlight,
          fontSize: 10.sp,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.redlight, width: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: bordercolor!, width: .5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: fillcolor!.withAlpha(80), width: 1),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: bordercolor!, width: .5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: bordercolor!, width: .5),
        ),
        label: Text(
          hint ?? '',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp),
          softWrap: true,
        ),
        labelStyle: TextStyles.inputtitle.copyWith(
          color: fillcolor!.withAlpha(150),
        ),
        floatingLabelStyle: TextStyles.inputtitle.copyWith(
          color: fillcolor!.withAlpha(150),
        ),
        // isDense: true,
        // contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}
