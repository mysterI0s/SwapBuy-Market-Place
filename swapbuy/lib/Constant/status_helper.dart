import 'package:flutter/material.dart';
import 'package:swapbuy/Constant/colors.dart';

class StatusHelper {
  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.grey;
      case 'accepted':
        return AppColors.green;
      case 'rejected':
        return AppColors.red;
      case 'cancelled':
        return AppColors.orange;
      default:
        return AppColors.grey;
    }
  }

  // Get status icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.help_outline;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // Check if status is actionable (can be accepted/rejected)
  static bool isActionable(String status) {
    return status.toLowerCase() == 'pending';
  }

  // Check if status is final (cannot be changed)
  static bool isFinal(String status) {
    return ['accepted', 'rejected', 'cancelled'].contains(status.toLowerCase());
  }

  // Get status display text
  static String getStatusText(String status) {
    return status;
  }
}
