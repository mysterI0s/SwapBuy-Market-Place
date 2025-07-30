import 'package:flutter/material.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Constant/status_helper.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool showIcon;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: StatusHelper.getStatusColor(status),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              StatusHelper.getStatusIcon(status),
              color: AppColors.white,
              size: fontSize ?? 14,
            ),
            SizedBox(width: 4),
          ],
          Text(
            StatusHelper.getStatusText(status),
            style: TextStyles.smallpra.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
