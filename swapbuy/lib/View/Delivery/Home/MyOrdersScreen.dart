import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/colors.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/Model/BuyOrder.dart';
import 'package:swapbuy/Model/SwapOrder.dart';
import 'package:swapbuy/Services/CustomDialog.dart';
import 'package:swapbuy/Services/ServicesProvider.dart';
import 'package:swapbuy/View/Delivery/Home/Controller/DeliveryOrderController.dart';
import 'package:swapbuy/Widgets/Button/ButtonCustom.dart';
import 'package:swapbuy/Model/Address.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();

    // Load my orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyOrders();
    });
  }

  Future<void> _loadMyOrders() async {
    final controller = Provider.of<DeliveryOrderController>(
      context,
      listen: false,
    );

    // Get delivery ID from services provider
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );
    final deliveryId = servicesProvider.deliveryId;

    if (deliveryId != null) {
      await controller.getMySwapOrders(context, deliveryId);
      await controller.getMyBuyOrders(context, deliveryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryOrderController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.thirdy),
          );
        }

        // Combine all my orders (excluding delivered ones)
        final allOrders = <Map<String, dynamic>>[];

        // Add swap orders (excluding delivered)
        for (var order in controller.mySwapOrders) {
          if (order.orderStatus != 'Delivered') {
            allOrders.add({'type': 'swap', 'order': order});
          }
        }

        // Add buy orders (excluding delivered)
        for (var order in controller.myBuyOrders) {
          if (order.orderStatus != 'Delivered') {
            allOrders.add({'type': 'buy', 'order': order});
          }
        }

        if (allOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64.sp,
                  color: AppColors.grey,
                ),
                Gap(16.h),
                Text(
                  'No Active Orders',
                  style: TextStyles.title.copyWith(color: AppColors.grey),
                ),
                Gap(8.h),
                Text(
                  'You don\'t have any orders in progress.\nCheck the Available tab to find orders or the Delivered tab for completed orders.',
                  style: TextStyles.paraghraph.copyWith(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadMyOrders,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: allOrders.length,
            itemBuilder: (context, index) {
              final orderData = allOrders[index];
              final type = orderData['type'] as String;
              final order = orderData['order'];

              if (type == 'swap') {
                return _buildSwapOrderCard(order as SwapOrder, controller);
              } else {
                return _buildBuyOrderCard(order as BuyOrder, controller);
              }
            },
          ),
        );
      },
    );
  }

  String formatAddress(Address? address) {
    if (address == null) return 'Not available';
    final parts = [
      if ((address.buildingNumber ?? '').isNotEmpty) address.buildingNumber,
      if ((address.street ?? '').isNotEmpty) address.street,
      if ((address.neighborhood ?? '').isNotEmpty) address.neighborhood,
      if ((address.city ?? '').isNotEmpty) address.city,
      if ((address.postalCode ?? '').isNotEmpty) address.postalCode,
      if ((address.country ?? '').isNotEmpty) address.country,
    ];
    return parts.join(', ');
  }

  Widget _buildSwapOrderCard(
    SwapOrder order,
    DeliveryOrderController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.basic,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price and Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.thirdy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 16.sp,
                        color: AppColors.thirdy,
                      ),
                      Gap(4.w),
                      Text(
                        'SWAP',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.thirdy,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyles.title.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.thirdy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Order Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _getStatusColor(order.status)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(order.status),
                    size: 16.sp,
                    color: _getStatusColor(order.status),
                  ),
                  Gap(8.w),
                  Text(
                    order.status ?? 'Pending',
                    style: TextStyles.paraghraph.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Pickup Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.store, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatAddress(order.seller?.address),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(8.h),
            // Delivery Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatAddress(order.deliveryAddress),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Separator
            Divider(color: Colors.grey.shade200, height: 1),
            Gap(12.h),

            // Status Update Buttons
            if (order.orderStatus != 'Delivered') ...[
              Row(
                children: [
                  Expanded(
                    child: ButtonCustom(
                      title: 'Update Status',
                      color: AppColors.thirdy,
                      onTap:
                          () => _showStatusUpdateDialog(
                            order,
                            controller,
                            'swap',
                          ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: ButtonCustom(
                      title: 'View Details',
                      color: AppColors.grey,
                      onTap: () => _viewOrderDetails(order, 'swap'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ButtonCustom(
                      title: 'View Details',
                      color: AppColors.thirdy,
                      onTap: () => _viewOrderDetails(order, 'swap'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBuyOrderCard(
    BuyOrder order,
    DeliveryOrderController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.basic,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price and Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.thirdy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16.sp,
                        color: AppColors.thirdy,
                      ),
                      Gap(4.w),
                      Text(
                        'BUY',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.thirdy,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyles.title.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.thirdy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Order Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _getStatusColor(order.orderStatus)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(order.orderStatus),
                    size: 16.sp,
                    color: _getStatusColor(order.orderStatus),
                  ),
                  Gap(8.w),
                  Text(
                    order.orderStatus ?? 'Pending',
                    style: TextStyles.paraghraph.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.orderStatus),
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Pickup Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.store, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatAddress(order.seller?.address),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(8.h),
            // Delivery Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.black, size: 20.sp),
                Gap(8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatAddress(order.deliveryAddress),
                        style: TextStyles.paraghraph.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Separator
            Divider(color: Colors.grey.shade200, height: 1),
            Gap(12.h),

            // Status Update Buttons
            if (order.orderStatus != 'Delivered') ...[
              Row(
                children: [
                  Expanded(
                    child: ButtonCustom(
                      title: 'Update Status',
                      color: AppColors.thirdy,
                      onTap:
                          () =>
                              _showStatusUpdateDialog(order, controller, 'buy'),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: ButtonCustom(
                      title: 'View Details',
                      color: AppColors.grey,
                      onTap: () => _viewOrderDetails(order, 'buy'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ButtonCustom(
                      title: 'View Details',
                      color: AppColors.thirdy,
                      onTap: () => _viewOrderDetails(order, 'buy'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods for status colors and icons
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.blue;
      case 'Preparing':
        return Colors.purple;
      case 'Out for Delivery':
        return Colors.indigo;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule;
      case 'Accepted':
        return Icons.check_circle;
      case 'Preparing':
        return Icons.build;
      case 'Out for Delivery':
        return Icons.local_shipping;
      case 'Delivered':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  // Status update dialog
  void _showStatusUpdateDialog(
    dynamic order,
    DeliveryOrderController controller,
    String type,
  ) {
    final currentStatus = order.orderStatus ?? 'Pending';
    final orderId = order.orderId;

    if (orderId == null) {
      CustomDialog.DialogError(context, title: 'Order ID not found');
      return;
    }

    final statusOptions = [
      'Pending',
      'Accepted',
      'Preparing',
      'Out for Delivery',
      'Delivered',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Status: $currentStatus'),
              Gap(16.h),
              Text('Select new status:'),
              Gap(8.h),
              ...statusOptions.map(
                (status) => RadioListTile<String>(
                  title: Text(status),
                  value: status,
                  groupValue: currentStatus,
                  onChanged: (String? value) {
                    if (value != null) {
                      Navigator.of(context).pop();
                      _updateOrderStatus(orderId, value, controller, type);
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Update order status
  Future<void> _updateOrderStatus(
    int orderId,
    String newStatus,
    DeliveryOrderController controller,
    String type,
  ) async {
    try {
      bool success = false;

      if (type == 'swap') {
        final result = await controller.updateSwapOrderStatus(
          context,
          orderId,
          newStatus,
        );
        success = result.fold((failure) => false, (result) => result);
      } else {
        final result = await controller.updateBuyOrderStatus(
          context,
          orderId,
          newStatus,
        );
        success = result.fold((failure) => false, (result) => result);
      }

      if (success) {
        CustomDialog.DialogSuccess(
          context,
          title: 'Status updated successfully',
        );
        // Refresh the orders list
        await _loadMyOrders();
      } else {
        CustomDialog.DialogError(context, title: 'Failed to update status');
      }
    } catch (e) {
      CustomDialog.DialogError(context, title: 'Error updating status: $e');
    }
  }

  // View order details
  void _viewOrderDetails(dynamic order, String type) {
    final controller = Provider.of<DeliveryOrderController>(
      context,
      listen: false,
    );
    controller.viewOrderDetails(context, order, type);
  }
}
